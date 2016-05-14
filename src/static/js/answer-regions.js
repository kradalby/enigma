var answerRegions = (function(){
	"use strict";
    /**
     * Hashtable which can use objects as keys
     */
    function HashTable() {
        this.hashes = {};
    }

    HashTable.prototype = {
        constructor: HashTable,

        add: function( key, value ) {
            this.hashes[ JSON.stringify( key ) ] = this.hashes[ JSON.stringify( key ) ] || [];
            this.hashes[ JSON.stringify( key ) ].push(value);
        },

        get: function( key ) {
            return this.hashes[ JSON.stringify( key ) ];
        },
        
        table: function(){
            return this.hashes;
        }
    };  
    
    /**
     * The real deal starts here.
     */
    var context,
        parentId,
        parentDiv,
        hiddenAnswerField,
        targetRegionColor,
        coloredRegions = [],
        colorsHashTable,
        regionColor,
        distanceToColorThreshold = 0,
        originalImage,
        answerImage,
        canvasHeight,
        canvasWidth,
        canvas,
        context,
        aspectRatio,
        questionId,
        regionCanvas,
        regionContext,
        regionData,
        
        /**
         * COMMON STUFF
         */
        
        relativeMouseCoordinates = function(event){
            var totalOffsetX = 0;
            var totalOffsetY = 0;
            var canvasX = 0;
            var canvasY = 0;
            var currentElement = document.getElementById(canvas.id);

            do{
                totalOffsetX += currentElement.offsetLeft;
                totalOffsetY += currentElement.offsetTop;
            }
            while(currentElement = currentElement.offsetParent)

            canvasX = event.pageX - totalOffsetX;
            canvasY = event.pageY - totalOffsetY;

            return {
                x: canvasX, 
                y: canvasY
            }
        },
        
        clearCanvas = function(){
            regionContext.clearRect(0, 0, canvasWidth, canvasHeight);
            context.clearRect(0, 0, canvasWidth, canvasHeight);
        },
        
        drawImage = function(contextDest, imgSrc, callback){
            var image = new Image();
            image.src = imgSrc;
            image.onload = function(){
                contextDest.drawImage(image, 0, 0, canvasWidth, canvasHeight);
                if(callback){
                    callback();
                }
            }
        },
        
        /**
         * LANDMARK RELATED
         */
        
        IsInsideColorRegion = function(coordinates, x, y){
            var existPointToLeft = false,
                existPointToRight = false,
                existPointAbove = false,
                existPointBelow = false;
            
            for(var i = 0; i < coordinates.length; i++){
                var coordinate = coordinates[i];
                if(!existPointAbove && coordinate.x === x && coordinate.y >= y){
                    existPointAbove = true;
                }
                if(!existPointBelow && coordinate.x === x && coordinate.y <= y){
                    existPointBelow = true;
                }
                if(!existPointToLeft && coordinate.x >= x && coordinate.y === y){
                    existPointToLeft = true;
                }
                if(!existPointToRight && coordinate.x <= x && coordinate.y === y){
                    existPointToRight = true;
                }
            }
            
            return existPointToLeft && existPointAbove && existPointBelow && existPointToRight;
        },

        IsCloseToColorRegion = function(points, x, y, threshold){
            for(var i = 0; i < points.length; i++){
                var point = points[i];
                var dx = point.x,
                    dy = point.y;
                var distance = Math.sqrt(Math.pow(x-dx, 2) + Math.pow(y-dy, 2));
                if(distance <= threshold){
                    return true;
                }
            }
            
            return false;
        },
        
        drawXOnMouseUp = function(){
            regionCanvas.addEventListener("mouseup", mouseUp, false);

            function drawX(x, y) {
                regionContext.beginPath();
                regionContext.strokeStyle="#FF0000";
                regionContext.lineWidth = 3;
                
                regionContext.moveTo(x - 10, y - 10);
                regionContext.lineTo(x + 10, y + 10);
                regionContext.stroke();

                regionContext.moveTo(x + 10, y - 10);
                regionContext.lineTo(x - 10, y + 10);
                regionContext.stroke();
            }

            function mouseUp(e) {
                var coords = relativeMouseCoordinates(e);
                drawImage(regionContext, originalImage, function(){
                    drawX(coords.x, coords.y);
                });
            }
        },
        
        updateHiddenAnswerOnMouseUp = function(){
            regionCanvas.addEventListener("mouseup", mouseUp, false);
            
            function mouseUp(e){
                for(var i = 0; i < coloredRegions.length; i++){
                    var region = coloredRegions[i];
                    if(IsInsideColorRegion(region.points, event.offsetX, event.offsetY) ||
                       IsCloseToColorRegion(region.points, event.offsetX, event.offsetY, distanceToColorThreshold)){
                        hiddenAnswerField.value = region.color;
                        return;
                    }
                }
                hiddenAnswerField.value = "{}";
            };
        },
        
        registerColoredRegions = function(imgSrc, callback)
        {
            var image = new Image();
            image.src = imgSrc;
            image.onload = function(){
                context.drawImage(image, 0, 0, canvasWidth, canvasHeight);
                regionData = context.getImageData(0, 0, canvasWidth, canvasHeight);
                var data = regionData.data;
                colorsHashTable = new HashTable();

                // Detect all colors
                for(var i = 0, n = data.length; i < n; i += 4){
                    var alpha = data[i + 3];
                    if(alpha == 255){
                        colorsHashTable.add({
                            red: data[i],
                            green: data[i+1],
                            blue: data[i+2],
                            alpha: alpha
                        },
                        {
                            x: Math.floor((i / 4) % canvasWidth), 
                            y: Math.floor((i / 4) / canvasWidth)
                        });
                    }
                }
                
                // Push the regions to global table
                var colorTable = colorsHashTable.table();
                for (var color in colorTable) {
                    if (colorTable.hasOwnProperty(color)) {
                        coloredRegions.push({
                            color: color,
                            points: colorTable[color]
                        });
                    }
                }
                
                clearCanvas();
                if(callback){
                    callback();
                }
            }
        },
        
        setImageRatios = function(height, width){
            aspectRatio = width / height;
            canvasHeight = Math.min(height, window.innerHeight);
            canvasWidth = canvasHeight * aspectRatio;
            context.canvas.height = canvasHeight;
            context.canvas.width = canvasWidth;
            regionContext.canvas.height = canvasHeight;
            regionContext.canvas.width = canvasWidth;

            canvasWidth = Math.min(canvasWidth, context.canvas.clientWidth);
            canvasHeight = Math.min(canvasHeight, context.canvas.clientHeight);
            context.canvas.height = canvasHeight;
            context.canvas.width = canvasWidth;
            regionContext.canvas.height = canvasHeight;
            regionContext.canvas.width = canvasWidth;
            
            var wrapperDiv = $(canvas).parent();
            wrapperDiv.width(canvasWidth);
            wrapperDiv.height(canvasHeight);
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
                return;
            }
            
            if(clear){
                clearCanvas();
                drawImage(context, originalImage);
            } else {
                drawRegionOutline();
            }
        },
        
        drawRegionOutline = function(){
            // For each point drawn
			for (var i = 0; i < clickX.length; i += 1) {
				// Set the drawing path
				regionContext.beginPath();
				// If dragging then draw a line between the two points
				if (clickDrag[i] && i) {
					regionContext.moveTo(clickX[i - 1], clickY[i - 1]);
				} else {
					// The x position is moved over one pixel so a circle even if not dragging
					regionContext.moveTo(clickX[i] - 1, clickY[i]);
				}
				regionContext.lineTo(clickX[i], clickY[i]);
				
                regionContext.strokeStyle = "#ff0000";
				regionContext.lineCap = "round";
				regionContext.lineJoin = "round";
				regionContext.lineWidth = lineWidth;
				regionContext.stroke();
			}
			regionContext.closePath();
			regionContext.restore();

			// Overlay a crayon texture (if the current tool is crayon)
			regionContext.globalAlpha = 1; // No IE support
        },

		// Adds a point to the drawing array.
		// @param x
		// @param y
		// @param dragging
		addClick = function (x, y, dragging) {
			clickX.push(x);
			clickY.push(y);
			clickDrag.push(dragging);
		},
        
        // Add mouse and touch event listeners to the canvas
		createUserEvents = function () {
			var press = function (e) {
				// Mouse down location
                var coords = relativeMouseCoordinates(e);
				paint = true;
				addClick(coords.x, coords.y, false);
				redraw();
			},

            drag = function (e) {
                if (paint) {
                    var coords = relativeMouseCoordinates(e);
                    addClick(coords.x, coords.y, true);
                    redraw();
                }
                // Prevent the whole page from dragging if on mobile
                e.preventDefault();
            },

            release = function () {
                paint = false;
                redraw();
            },

            cancel = function () {
                paint = false;
            };
			// Add mouse event listeners to canvas element
			regionCanvas.addEventListener("mousedown", press, false);
			regionCanvas.addEventListener("mousemove", drag, false);
			regionCanvas.addEventListener("mouseup", release);
			regionCanvas.addEventListener("mouseout", cancel, false);

			// Add touch event listeners to canvas element
			regionCanvas.addEventListener("touchstart", press, false);
			regionCanvas.addEventListener("touchmove", drag, false);
			regionCanvas.addEventListener("touchend", release, false);
			regionCanvas.addEventListener("touchcancel", cancel, false);
		},

		// Calls the redraw function after all neccessary resources are loaded.
		resourceLoaded = function () {
            imageLoaded = true;
            redraw();
            createUserEvents();
		},
        
        clearOutline = function(colorIndex){
            clickY = [];
            clickX = [];
            clickDrag = [];
            redraw(true);
        },
        
        updateHiddenOutlineAnswerOnMouseUp = function(){
            regionCanvas.addEventListener("mouseup", mouseUp, false);
            
            function mouseUp(e){
                var targetRegionPoints = colorsHashTable.get(targetRegionColor);
                var data = regionContext.getImageData(0, 0, canvasWidth, canvasHeight).data;
                var pixelsHit = 0;
                var pixelsTargetTotal = targetRegionPoints.length;
                
                for (var index in targetRegionPoints) {
                    if (targetRegionPoints.hasOwnProperty(index)) {
                        var x = targetRegionPoints[index].x;
                        var y = targetRegionPoints[index].y;
                        var dataIndex = (y * canvasWidth * 4) + x * 4;
                        if(data[dataIndex] == 255 && data[dataIndex + 1] == 0 && data[dataIndex + 2] == 0 && data[dataIndex + 3] == 255){
                            pixelsHit++;
                        }
                    }
                }
                
                hiddenAnswerField.value = JSON.stringify({
                    "pixelsHit" : pixelsHit,
                    "pixelsTotal" : pixelsTargetTotal
                });
            };
        },
        
        setTargetRegion = function(questionId){
            var hexColor = document.getElementById("region-" + questionId + "-color").getAttribute("value");
            targetRegionColor = {
                "red": parseInt(hexColor.substring(1,3), 16),
                "green": parseInt(hexColor.substring(3,5), 16),
                "blue": parseInt(hexColor.substring(5,7), 16),
                "alpha":255
            };
        },
        
        /**
         *  EXPORTED
         */
        enableCommon = function(targetDivId, image, answerImg, height, width, id){
            parentId = targetDivId;
            parentDiv = document.getElementById(parentId);
            questionId = id;
            
            // Create canvas
            canvas = document.createElement('canvas');
            canvas.style.zIndex = "1";
            parentDiv.appendChild(canvas);
            if (typeof G_vmlCanvasManager !== "undefined") {
				canvas = G_vmlCanvasManager.initElement(canvas);
			}
            context = canvas.getContext('2d');
            
            // Create region canvas
            regionCanvas = document.createElement('canvas');
            regionCanvas.style.zIndex = "2";
            parentDiv.appendChild(regionCanvas);
            if (typeof G_vmlCanvasManager !== "undefined") {
				regionCanvas = G_vmlCanvasManager.initElement(regionCanvas);
			}
            regionContext = regionCanvas.getContext('2d');
            regionCanvas.id = "region_canvas-" + questionId;
            
            // Create hidden answer field
            hiddenAnswerField = document.createElement("input");
            hiddenAnswerField.setAttribute("type", "hidden");
            hiddenAnswerField.setAttribute("value", "{}");
            parentDiv.appendChild(hiddenAnswerField);

            // Register other necessities
            setTargetRegion(questionId);
            originalImage = image;
            answerImage = answerImg;
            setImageRatios(height, width);
        },
        
        enableLandmark = function(targetDivId, image, answerImg, height, width, id){
            enableCommon(targetDivId, image, answerImg, height, width, id);
            
            canvas.id = "landmark_canvas-" + questionId;
            hiddenAnswerField.setAttribute("name", "landmark_question-" + questionId);
            
            registerColoredRegions(answerImage, function(){
                drawImage(context, originalImage);
            });
            
            drawXOnMouseUp();
            updateHiddenAnswerOnMouseUp();
        },
        
        enableOutline = function(targetDivId, image, answerImg, height, width, id){
            enableCommon(targetDivId, image, answerImg, height, width, id);
            
            canvas.id = "outline_canvas-" + questionId;
            hiddenAnswerField.setAttribute("name", "outline_question-" + questionId);
            
            registerColoredRegions(answerImage, function(){
                drawImage(context, originalImage);
                resourceLoaded();
            });
            
            updateHiddenOutlineAnswerOnMouseUp();
        };

    return {
		enableLandmark: enableLandmark,
		enableOutline: enableOutline,
        clearOutline: clearOutline
	};
});
