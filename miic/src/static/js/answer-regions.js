var answerRegions = function () {
  'use strict'
  /**
   * Hashtable which can use objects as keys
   */
  function HashTable () {
    this.hashes = {}
  }

  HashTable.prototype = {
    constructor: HashTable,

    add: function (key, value) {
      this.hashes[JSON.stringify(key)] = this.hashes[JSON.stringify(key)] || []
      this.hashes[JSON.stringify(key)].push(value)
    },

    get: function (key) {
      return this.hashes[JSON.stringify(key)]
    },

    table: function () {
      return this.hashes
    }
  }

  /**
   * The real deal starts here.
   */
  var context,
    parentDiv,
    hiddenAnswerField,
    hiddenImageData,
    targetRegionColor,
    drawColor = '#c02f1d',
    coloredRegions = [],
    colorsHashTable,
    originalImage,
    canvasHeight,
    canvasWidth,
    canvas,
    questionId,
    regionCanvas,
    regionContext,
    regionData,
    clicksAddedSinceLastCalculation = false,
    erasing = false,
    erase = [],
    isOutline = false,

    /**
     * COMMON STUFF
     */

    relativeMouseCoordinates = function (event) {
      var totalOffsetX = 0
      var totalOffsetY = 0
      var canvasX = 0
      var canvasY = 0
      var currentElement = document.getElementById(canvas.id)
      var origX = event.pageX
      if (!origX) {
        origX = event.changedTouches[0].pageX
      }
      if (!origY) {
        var origY = event.pageY || event.changedTouches[0].pageY
      }

      do {
        totalOffsetX += currentElement.offsetLeft
        totalOffsetY += currentElement.offsetTop
      }
      while (currentElement = currentElement.offsetParent)
      canvasX = origX - totalOffsetX
      canvasY = origY - totalOffsetY

      return {
        x: canvasX,
        y: canvasY
      }
    },

    clearCanvas = function () {
      regionContext.clearRect(0, 0, canvasWidth, canvasHeight)
      context.clearRect(0, 0, canvasWidth, canvasHeight)
    },

    drawImage = function (contextDest, imgSrc, callback) {
      var image = new Image()
      image.src = imgSrc
      image.onload = function () {
        contextDest.drawImage(image, 0, 0, canvasWidth, canvasHeight)
        if (callback) {
          callback()
        }
      }
    },

    /**
     * LANDMARK RELATED
     */

    drawXOnMouseUp = function () {
      regionCanvas.addEventListener('mouseup', mouseUp, false)

      function drawX (x, y) {
        regionContext.beginPath()
        regionContext.strokeStyle = drawColor
        regionContext.lineWidth = 3

        regionContext.moveTo(x - 10, y - 10)
        regionContext.lineTo(x + 10, y + 10)
        regionContext.stroke()

        regionContext.moveTo(x + 10, y - 10)
        regionContext.lineTo(x - 10, y + 10)
        regionContext.stroke()
      }

      function mouseUp (e) {
        var coords = relativeMouseCoordinates(e)
        drawImage(regionContext, originalImage, function () {
          drawX(coords.x, coords.y)
          updateHiddenImageData()
        })
      }
    },

    updateHiddenAnswerOnMouseUp = function () {
      regionCanvas.addEventListener('mouseup', mouseUp, false)

      function mouseUp (e) {
        var data = regionData.data,
          dataIndex = (event.offsetY * canvasWidth * 4) + event.offsetX * 4,
          red = data[dataIndex],
          green = data[dataIndex + 1],
          blue = data[dataIndex + 2],
          alpha = data[dataIndex + 3]
        if (alpha !== 0 && (red !== 0 || green !== 0 || blue !== 0)) {
          hiddenAnswerField.value = JSON.stringify({
            'red': red,
            'green': green,
            'blue': blue,
            'alpha': 255
          })
        } else {
          hiddenAnswerField.value = '{}'
        }
      };
    },

    registerColoredRegions = function (imgSrc, callback) {
      var image = new Image()
      image.src = imgSrc
      image.onload = function () {
        context.drawImage(image, 0, 0, canvasWidth, canvasHeight)
        regionData = context.getImageData(0, 0, canvasWidth, canvasHeight)
        var data = regionData.data
        colorsHashTable = new HashTable()

        // Detect all colors
        for (var i = 0, n = data.length; i < n; i += 4) {
          var alpha = data[i + 3]
          if (alpha == 255) {
            colorsHashTable.add({
              red: data[i],
              green: data[i + 1],
              blue: data[i + 2],
              alpha: alpha
            },
              {
                x: Math.floor((i / 4) % canvasWidth),
                y: Math.floor((i / 4) / canvasWidth)
              })
          }
        }

        // Push the regions to global table
        var colorTable = colorsHashTable.table()
        for (var color in colorTable) {
          if (colorTable.hasOwnProperty(color)) {
            coloredRegions.push({
              color: color,
              points: colorTable[color]
            })
          }
        }

        clearCanvas()
        if (callback) {
          callback()
        }
      }
    },

    setImageRatios = function (height, width) {
      var aspectRatio = width / height
      canvasHeight = Math.min(height, window.innerHeight * 0.65)
      canvasWidth = canvasHeight * aspectRatio
      context.canvas.height = canvasHeight
      context.canvas.width = canvasWidth
      regionContext.canvas.height = canvasHeight
      regionContext.canvas.width = canvasWidth

      canvasWidth = Math.min(canvasWidth, context.canvas.clientWidth)
      canvasHeight = Math.min(canvasHeight, context.canvas.clientHeight)
      context.canvas.height = canvasHeight
      context.canvas.width = canvasWidth
      regionContext.canvas.height = canvasHeight
      regionContext.canvas.width = canvasWidth

      var wrapperDiv = $(canvas).parent()
      wrapperDiv.width(canvasWidth)
      wrapperDiv.height(canvasHeight)
    },

    /**
     * OUTLINE SPECIFIC
     */
    lineWidth = 5,
    clickX = [],
    clickY = [],
    clickDrag = [],
    paint = false,
    imageLoaded = false,

    redraw = function (clear) {
      if (!imageLoaded) {
        return
      }

      if (clear) {
        clearCanvas()
        drawImage(context, originalImage, updateHiddenImageData)
      } else {
        drawRegionOutline()
        updateHiddenImageData()
      }
    },

    drawRegionOutline = function () {
      // For each point drawn
      for (var i = 0; i < clickX.length; i += 1) {
        // Set the drawing path
        regionContext.beginPath()
        // If dragging then draw a line between the two points
        if (clickDrag[i] && i) {
          regionContext.moveTo(clickX[i - 1], clickY[i - 1])
        } else {
          // The x position is moved over one pixel so a circle even if not dragging
          regionContext.moveTo(clickX[i] - 1, clickY[i])
        }
        regionContext.lineTo(clickX[i], clickY[i])

        if (erase[i]) {
          regionContext.globalCompositeOperation = 'destination-out'
          regionContext.strokeStyle = 'rgba(0,0,0,1.0)'
          regionContext.lineWidth = 15
        } else {
          regionContext.globalCompositeOperation = 'source-over'
          regionContext.strokeStyle = drawColor
          regionContext.lineWidth = lineWidth
        }

        regionContext.lineCap = 'round'
        regionContext.lineJoin = 'round'
        regionContext.stroke()
      }
      regionContext.closePath()
      regionContext.restore()

      regionContext.globalAlpha = 1
      regionContext.globalCompositeOperation = 'source-over'
    },

    addClick = function (x, y, dragging) {
      clickX.push(x)
      clickY.push(y)
      clickDrag.push(dragging)
      clicksAddedSinceLastCalculation = true
      erase.push(erasing)
    },

    createUserEvents = function () {
      var press = function (e) {
        // Mouse down location
          var coords = relativeMouseCoordinates(e)
          paint = true
          addClick(coords.x, coords.y, false)
          redraw()
        },

        drag = function (e) {
          if (paint) {
            var coords = relativeMouseCoordinates(e)
            addClick(coords.x, coords.y, true)
            redraw()
          }
          // Prevent the whole page from dragging if on mobile
          e.preventDefault()
        },

        release = function () {
          paint = false
          redraw()
        },

        cancel = function () {
          paint = false
        }
      // Add mouse event listeners to canvas element
      regionCanvas.addEventListener('mousedown', press, false)
      regionCanvas.addEventListener('mousemove', drag, false)
      regionCanvas.addEventListener('mouseup', release)
      regionCanvas.addEventListener('mouseout', cancel, false)

      // Add touch event listeners to canvas element
      regionCanvas.addEventListener('touchstart', press, false)
      regionCanvas.addEventListener('touchmove', drag, false)
      regionCanvas.addEventListener('touchend', release, false)
      regionCanvas.addEventListener('touchcancel', cancel, false)
    },

    // Calls the redraw function after all neccessary resources are loaded.
    resourceLoaded = function () {
      imageLoaded = true
      redraw()
      createUserEvents()
    },

    clearOutline = function () {
      clickY = []
      clickX = []
      clickDrag = []
      redraw(true)
    },

    updateOutlineAnswer = function () {
      function distance (x1, y1, x2, y2) {
        return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2))
      }

      function closestPoint (data, x2, y2) {
        var closest = 4200
        for (var i = 0; i < data.length; i += 4 * 5) {
          if (data[i] === 192 &&
            data[i + 1] === 47 &&
            data[i + 2] === 29 &&
            data[i + 3] === 255) {
            var x1 = Math.floor((i / 4) % canvasWidth)
            var y1 = Math.floor((i / 4) / canvasWidth)
            var currentDistance = distance(x1, y1, x2, y2)
            if (currentDistance < closest) {
              closest = currentDistance
            }
          }
        }
        return closest
      }

      if (!clicksAddedSinceLastCalculation || !isOutline) {
        return
      }

      $('#outlineModal').modal('show')
      setTimeout(function () {
        var targetRegionPoints = colorsHashTable.get(targetRegionColor)
        var data = regionContext.getImageData(0, 0, canvasWidth, canvasHeight).data
        var totalDistance = 0
        for (var index in targetRegionPoints) {
          if (targetRegionPoints.hasOwnProperty(index)) {
            var x2 = targetRegionPoints[index].x
            var y2 = targetRegionPoints[index].y
            totalDistance += closestPoint(data, x2, y2)
          }
        }
        hiddenAnswerField.value = totalDistance / targetRegionPoints.length
        $('#outlineModal').modal('hide')
        clicksAddedSinceLastCalculation = false
      }, 25)
    },

    hexColorToJson = function (hexColor) {
      return {
        'red': parseInt(hexColor.substring(1, 3), 16),
        'green': parseInt(hexColor.substring(3, 5), 16),
        'blue': parseInt(hexColor.substring(5, 7), 16),
        'alpha': 255
      }
    },

    setTargetRegion = function (questionId) {
      var hexColor = document.getElementById('region-' + questionId + '-color').getAttribute('value')
      targetRegionColor = hexColorToJson(hexColor)
    },

    updateHiddenImageData = function () {
      var imageData = regionCanvas.toDataURL('image/png')
      hiddenImageData.value = imageData
    },

    addRubberButton = function () {
      var rubberButton = $('<div class="btn btn-default pull-right"><span class="glyphicon glyphicon-erase" aria-hidden="true"></span></div>')
      $(parentDiv)
        .parent()
        .parent()
        .children('.panel-heading')
        .prepend(rubberButton)
      $(rubberButton).click(function () {
        enableEraser(true)
      })
    },

    addPencilButton = function () {
      var pencilButton = $('<div class="btn btn-default pull-right"><span class="glyphicon glyphicon-pencil" aria-hidden="true"></span></div>')
      $(parentDiv)
        .parent()
        .parent()
        .children('.panel-heading')
        .prepend(pencilButton)
      $(pencilButton).click(function () {
        enableEraser(false)
      })
    },

    enableEraser = function (eraseOn) {
      erasing = eraseOn
      if (eraseOn) {
        $(parentDiv).addClass('erase')
      } else {
        $(parentDiv).removeClass('erase')
      }
    },

    /**
     *  EXPORTED
     */
    enableCommon = function (targetDivId, image, answerImg, height, width, id) {
      parentDiv = document.getElementById(targetDivId)
      questionId = id

      // Create canvas
      canvas = document.createElement('canvas')
      canvas.style.zIndex = '1'
      parentDiv.appendChild(canvas)
      if (typeof G_vmlCanvasManager !== 'undefined') {
        canvas = G_vmlCanvasManager.initElement(canvas)
      }
      context = canvas.getContext('2d')

      // Create region canvas
      regionCanvas = document.createElement('canvas')
      regionCanvas.style.zIndex = '2'
      parentDiv.appendChild(regionCanvas)
      if (typeof G_vmlCanvasManager !== 'undefined') {
        regionCanvas = G_vmlCanvasManager.initElement(regionCanvas)
      }
      regionContext = regionCanvas.getContext('2d')
      regionCanvas.id = 'region_canvas-' + questionId

      // Create hidden answer field
      hiddenAnswerField = document.createElement('input')
      hiddenAnswerField.setAttribute('type', 'hidden')
      hiddenAnswerField.setAttribute('value', '')
      parentDiv.appendChild(hiddenAnswerField)

      // Create hidden image field
      hiddenImageData = document.createElement('input')
      hiddenImageData.setAttribute('type', 'hidden')
      hiddenImageData.setAttribute('value', '')
      hiddenImageData.setAttribute('name', 'hidden-image-data-' + questionId)
      parentDiv.appendChild(hiddenImageData)

      // Register other necessities
      if (answerImg) {
        setTargetRegion(questionId)
      }
      originalImage = image
      setImageRatios(height, width)
      addPencilButton()
      // addRubberButton();

      // We have to do the following because the next button does not exist yet...
      $(document).on('click', 'li.next > a.test-navigation', function () {
        {
          updateOutlineAnswer()
        }
      })
    },

    enableLandmark = function (targetDivId, image, answerImg, height, width, id) {
      enableCommon(targetDivId, image, answerImg, height, width, id)

      canvas.id = 'landmark_canvas-' + questionId
      hiddenAnswerField.setAttribute('name', 'landmark_question-' + questionId)

      registerColoredRegions(answerImg, function () {
        drawImage(context, originalImage)
      })

      drawXOnMouseUp()
      updateHiddenAnswerOnMouseUp()
    },

    enableOutline = function (targetDivId, image, answerImg, height, width, id) {
      enableCommon(targetDivId, image, answerImg, height, width, id)

      canvas.id = 'outline_canvas-' + questionId
      hiddenAnswerField.setAttribute('name', 'outline_question-' + questionId)
      isOutline = true

      registerColoredRegions(answerImg, function () {
        drawImage(context, originalImage)
        resourceLoaded()
      })

      var clearButtonDiv = $('<div class="btn btn-default pull-right">Clear</div>')
      $(parentDiv)
        .parent()
        .parent()
        .children('.panel-heading')
        .prepend(clearButtonDiv)
      clearButtonDiv.click(function () {
        clearOutline()
      })
    },

    enableOutlineSolution = function (targetDivId, image, height, width, id) {
      enableCommon(targetDivId, image, null, height, width, id)

      canvas.id = 'outline_solution_canvas-' + questionId
      hiddenAnswerField.setAttribute('name', 'outline_solution_question-' + questionId)

      drawImage(context, originalImage, function () {
        resourceLoaded()
      })

      var clearButtonDiv = $('<div class="btn btn-default pull-right">Clear</div>')
      $(parentDiv)
        .parent()
        .parent()
        .children('.panel-heading')
        .prepend(clearButtonDiv)
      clearButtonDiv.click(function () {
        clearOutline()
      })
      lineWidth = 2
    },

    enableImageSuggestion = function (targetDivId, image, height, width, id) {
      enableCommon(targetDivId, image, null, height, width, id)

      canvas.id = 'image_suggestion-' + questionId
      hiddenAnswerField.setAttribute('name', 'image_suggestion-' + questionId)

      drawImage(context, originalImage, function () {
        resourceLoaded()
      })

      var clearButtonDiv = $('<div class="btn btn-default pull-right">Clear</div>')
      $(parentDiv)
        .parent()
        .parent()
        .children('.panel-heading')
        .prepend(clearButtonDiv)
      clearButtonDiv.click(function () {
        clearOutline()
      })
      lineWidth = 2
    }

  return {
    enableLandmark: enableLandmark,
    enableOutline: enableOutline,
    enableOutlineSolution: enableOutlineSolution,
    enableImageSuggestion: enableImageSuggestion
  }
}
