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
        coloredRegions = [],
        distanceToColorThreshold = 0,
        originalImage,
        answerImage,
        canvasHeight,
        canvasWidth,
        canvas,
        context,
        aspectRatio,
        questionId,
        
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
            context.clearRect(0, 0, canvas.width, canvas.height);
        },
        
        drawImage = function(imgSrc, callback){
            var image = new Image();
            image.src = imgSrc;
            image.onload = function(){
                context.drawImage(image, 0, 0, canvasWidth, canvasHeight);
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
            canvas.addEventListener("mouseup", mouseUp, false);

            function drawX(x, y) {
                context.beginPath();
                context.strokeStyle="#FF0000";
                context.lineWidth = 3;
                
                context.moveTo(x - 10, y - 10);
                context.lineTo(x + 10, y + 10);
                context.stroke();

                context.moveTo(x + 10, y - 10);
                context.lineTo(x - 10, y + 10);
                context.stroke();
            }

            function mouseUp(e) {
                var coords = relativeMouseCoordinates(e);
                clearCanvas();
                drawImage(originalImage, function(){
                    drawX(coords.x, coords.y);
                });
            }
        },
        
        updateHiddenAnswerOnMouseUp = function(){
            canvas.addEventListener("mouseup", mouseUp, false);
            
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
                var imageData = context.getImageData(0, 0, canvasWidth, canvasHeight);
                var data = imageData.data;
                var colors = new HashTable();

                // Detect all colors
                for(var i = 0, n = data.length; i < n; i += 4){
                    var alpha = data[i + 3];
                    if(alpha == 255){
                        colors.add({
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
                var colorTable = colors.table();
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

            canvasWidth = Math.min(canvasWidth, context.canvas.clientWidth);
            canvasHeight = Math.min(canvasHeight, context.canvas.clientHeight);
            context.canvas.height = canvasHeight;
            context.canvas.width = canvasWidth;
            
        },
        
        /**
         * OUTLINE SPECIFIC
         */
        lineWidth = 5,
		clickX = [],
		clickY = [],
		clickColor = [],
		clickDrag = [],
		paint = false,
		curColor = "#ff0000",
		imageLoaded = false,
        
        redraw = function () {
            if (!imageLoaded) {
                return;
            }

            //clearCanvas();
            //drawRegionOutline();
            //updateHiddenImageData();
            clearCanvas();
            drawImage(originalImage, function(){
                drawRegionOutline();
            });
        },
        
        drawRegionOutline = function(){
            // For each point drawn
			for (var i = 0; i < clickX.length; i += 1) {
				// Set the drawing path
				context.beginPath();
				// If dragging then draw a line between the two points
				if (clickDrag[i] && i) {
					context.moveTo(clickX[i - 1], clickY[i - 1]);
				} else {
					// The x position is moved over one pixel so a circle even if not dragging
					context.moveTo(clickX[i] - 1, clickY[i]);
				}
				context.lineTo(clickX[i], clickY[i]);
				
                context.strokeStyle = clickColor[i];
				context.lineCap = "round";
				context.lineJoin = "round";
				context.lineWidth = lineWidth;
				context.stroke();
			}
			context.closePath();
			context.restore();

			// Overlay a crayon texture (if the current tool is crayon)
			context.globalAlpha = 1; // No IE support
        },

		// Adds a point to the drawing array.
		// @param x
		// @param y
		// @param dragging
		addClick = function (x, y, dragging) {
			clickX.push(x);
			clickY.push(y);
			clickColor.push(curColor);
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
			canvas.addEventListener("mousedown", press, false);
			canvas.addEventListener("mousemove", drag, false);
			canvas.addEventListener("mouseup", release);
			canvas.addEventListener("mouseout", cancel, false);

			// Add touch event listeners to canvas element
			canvas.addEventListener("touchstart", press, false);
			canvas.addEventListener("touchmove", drag, false);
			canvas.addEventListener("touchend", release, false);
			canvas.addEventListener("touchcancel", cancel, false);
		},

		// Calls the redraw function after all neccessary resources are loaded.
		resourceLoaded = function () {
            imageLoaded = true;
            redraw();
            createUserEvents();
		},
        
        clearColor = function(colorIndex){
            var colorToRemove = curColor;
            for(var i = clickColor.length - 1; i >= 0; i--) {
                if(clickColor[i] === colorToRemove) {
                    clickColor.splice(i, 1);
                    clickY.splice(i, 1);
                    clickX.splice(i, 1);
                    clickDrag.splice(i, 1);
                }
            }
            redraw();
        },
        
        updateHiddenImageData = function(){
            var imageData = canvas.toDataURL("image/png");
            hiddenAnswerField.value = imageData;
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
            parentDiv.appendChild(canvas);
            if (typeof G_vmlCanvasManager !== "undefined") {
				canvas = G_vmlCanvasManager.initElement(canvas);
			}
            context = canvas.getContext('2d');
            
            // Create hidden answer field
            hiddenAnswerField = document.createElement("input");
            hiddenAnswerField.setAttribute("type", "hidden");
            hiddenAnswerField.setAttribute("value", "{}");
            parentDiv.appendChild(hiddenAnswerField);

            // Register other necessities
            originalImage = image;
            answerImage = answerImg;
            setImageRatios(height, width);
        },
        
        enableLandmark = function(targetDivId, image, answerImg, height, width, id){
            enableCommon(targetDivId, image, answerImg, height, width, id);
            
            canvas.id = "landmark_canvas-" + questionId;
            hiddenAnswerField.setAttribute("name", "landmark_question-" + questionId);
            
            registerColoredRegions(answerImage, function(){
                drawImage(originalImage);
            });
            
            updateHiddenAnswerOnMouseUp();
            drawXOnMouseUp();
        },
        
        enableOutline = function(targetDivId, image, answerImg, height, width, id){
            enableCommon(targetDivId, image, answerImg, height, width, id);
            
            canvas.id = "landmark_outline-" + questionId;
            hiddenAnswerField.setAttribute("name", "outline_question-" + questionId);
            
            registerColoredRegions(answerImage, function(){
                drawImage(originalImage);
                resourceLoaded();
            });
        };

    return {
		enableLandmark: enableLandmark,
		enableOutline: enableOutline
	};
});
