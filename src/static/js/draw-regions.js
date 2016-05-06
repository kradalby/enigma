var drawRegions = (function () {
	"use strict";

	var canvas,
		context,
		canvasWidth,
		canvasHeight,
        lineWidth = 5,
        colors = [],
		outlineImage = new Image(),
		clickX = [],
		clickY = [],
		clickColor = [],
		clickDrag = [],
		paint = false,
		curColor = colors[1],
		imageLoaded = false,

		// Clears the canvas.
		clearCanvas = function () {
			context.clearRect(0, 0, canvasWidth, canvasHeight);
		},
        
        drawOriginalImage = function () {
			context.drawImage(outlineImage, 0, 0, canvasWidth, canvasHeight);
        },

		// Redraws the canvas.
		redraw = function () {
			if (!imageLoaded) {
				return;
			}

			clearCanvas();
            drawRegionOutline();
            updateHiddenImageData();
			clearCanvas();
            drawOriginalImage();
            drawRegionOutline();
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
            
        relativeMouseCoordinates = function(event){
            var totalOffsetX = 0;
            var totalOffsetY = 0;
            var canvasX = 0;
            var canvasY = 0;
            var currentElement = canvas;

            do{
                totalOffsetX += currentElement.offsetLeft - currentElement.scrollLeft;
                totalOffsetY += currentElement.offsetTop - currentElement.scrollTop;
            }
            while(currentElement = currentElement.offsetParent)

            canvasX = event.pageX - totalOffsetX;
            canvasY = event.pageY - totalOffsetY;

            return {x:canvasX, y:canvasY}
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
        
        addColor = function(color){
            colors.push(color);
        },
        
        setColor = function(colorIndex){
            curColor = colors[colorIndex];
        },
        
        clearColor = function(colorIndex){
            var colorToRemove = colors[colorIndex];
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
            var imageData = document.getElementById('canvas').toDataURL("image/png");
            document.getElementById('hidden-image-data').value = imageData;
        },

		// Creates a canvas element, loads images, adds events, and draws the canvas for the first time.
		init = function (image, height, width) {
            canvasHeight = height;
            canvasWidth = width;
            
            // Ensure canvas is not too wide
            var leftColumnWidth = 800;
            if(canvasWidth > leftColumnWidth){
                var shrinkRatio = canvasWidth / leftColumnWidth;
                canvasWidth /= shrinkRatio;
                canvasHeight /= shrinkRatio;
            }

			// Create the canvas (Neccessary for IE because it doesn't know what a canvas element is)
			canvas = document.createElement('canvas');
			canvas.setAttribute('width', canvasWidth);
			canvas.setAttribute('height', canvasHeight);
			canvas.setAttribute('id', 'canvas');
			document.getElementById('canvasDiv').appendChild(canvas);
			if (typeof G_vmlCanvasManager !== "undefined") {
				canvas = G_vmlCanvasManager.initElement(canvas);
			}
			context = canvas.getContext("2d"); // Grab the 2d canvas context
			// Note: The above code is a workaround for IE 8 and lower. Otherwise we could have used:
			//     context = document.getElementById('canvas').getContext("2d");

			outlineImage.onload = resourceLoaded;
            outlineImage.src = image;
		};

	return {
		init: init,
        setColor : setColor,
        clearColor : clearColor,
        addColor : addColor
	};
}());