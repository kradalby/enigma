var drawRegions = (function () {
	"use strict";

	var canvas,
		context,
		canvasWidth,
		canvasHeight,
        lineWidth = 2,
        colors = [],
		rgbColors = [],
		originalImage,
		clickX = [],
		clickY = [],
		clickWidth = [],
		clickColor = [],
		clickDrag = [],
		paint = false,
		curColor = colors[1],
		imageLoaded = false,
		erase = [],
		erasing = false,
		parentId,
		parentDiv,
		regionCanvas,
		regionContext,
		aspectRatio,

		clearCanvas = function () {
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
		
		removeColor = function(color){
			var canvasData = regionContext.getImageData(0, 0, canvasWidth, canvasHeight),
				pix = canvasData.data;

			for (var i = 0; i < pix.length; i += 4) {
				if(pix[i] === color[0] && pix[i+1] === color[1] && pix[i+2] === color[2]){
					pix[i+3] = 0;
				}
				if(!isARegisteredColor([pix[i],pix[i+1],pix[i+2],pix[i+3]])){
					// Remove anti-aliased colors
					pix[i+3] = 0;
				}
			}
			regionContext.putImageData(canvasData, 0, 0);
		},
		
		isARegisteredColor = function(color){
			if(color[3] === 0){
				return false;
			}
			
			for(var i = 0; i < rgbColors.length; i++){
				var rgbColor = rgbColors[i];
				if(rgbColor[0] === color[0] && rgbColor[1] === color[1] && rgbColor[2] === color[2]){
					return true;
				}
			}
			return false;
		},

		redraw = function (clear) {
            if (!imageLoaded) {
                return;
            }
            
            if(clear){
                clearCanvas();
                drawImage(context, originalImage);
            }
			drawRegionOutline();
        },
        
        drawRegionOutline = function(){
			for (var i = 0; i < clickX.length; i += 1) {
				regionContext.beginPath();
				if (clickDrag[i] && i) {
					regionContext.moveTo(clickX[i - 1], clickY[i - 1]);
				} else {
					regionContext.moveTo(clickX[i] - 1, clickY[i]);
				}
				regionContext.lineTo(clickX[i], clickY[i]);
				
				if(erase[i]){
					regionContext.globalCompositeOperation = "destination-out";
					regionContext.strokeStyle = "rgba(0,0,0,1.0)";
					regionContext.lineWidth = 15;
				}else{
					regionContext.globalCompositeOperation = "source-over";
					regionContext.strokeStyle = clickColor[i];
					regionContext.lineWidth = clickWidth[i];
				}
				regionContext.lineCap = "round";
				regionContext.lineJoin = "round";
				regionContext.stroke();
			}
			regionContext.closePath();
			regionContext.restore();
			context.globalCompositeOperation = "source-over";
			regionContext.globalAlpha = 1;
        },
		
		addClick = function (x, y, dragging) {
			clickX.push(x);
			clickY.push(y);
			clickColor.push(curColor);
			clickDrag.push(dragging);
			clickWidth.push(lineWidth);
			erase.push(erasing);
		},
            
        relativeMouseCoordinates = function(event){
            var totalOffsetX = 0;
            var totalOffsetY = 0;
            var canvasX = 0;
            var canvasY = 0;
            var currentElement = canvas;

            do{
                totalOffsetX += currentElement.offsetLeft;
                totalOffsetY += currentElement.offsetTop;
            }
            while(currentElement = currentElement.offsetParent)

            canvasX = event.pageX - totalOffsetX;
            canvasY = event.pageY - totalOffsetY;

            return {
				x : canvasX, 
				y : canvasY
			}
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
				updateHiddenImageData();
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
            redraw(true);
            createUserEvents();
		},
        
        addColor = function(color){
            colors.push(color);

			var colorWithoutHash = "0x" + color.substring(1);
			var r = colorWithoutHash >> 16;
			var g = colorWithoutHash >> 8 & 0xFF;
			var b = colorWithoutHash & 0xFF;
			rgbColors.push([r,g,b]);
        },
		
		deleteColor = function(color){
			for(var i = 0; i < colors.length; i++){
				if(colors[i] == color){
					clearColor(colors[i]);
                    colors.splice(i, 1);
                    rgbColors.splice(i, 1);
				}
			}
		},
		
		eraseColor = function(eraseOn){
			erasing = eraseOn;
			if(eraseOn){
				$(parentDiv).addClass("erase");
			}else{
				console.log("REMOVE")
				$(parentDiv).removeClass("erase");
			}
		},
        
        setColor = function(color){
			for(var i = 0; i < colors.length; i++){
				if(colors[i] == color){
					curColor = color;
					eraseColor(false);
					break;
				}
			}
        },
		
		getCurrentColor = function() {
			return curColor;
		},
        
        clearColor = function(color){
			var colorIndex = -1;
			for(var i = 0; i < colors.length; i++){
				if(color == colors[i]){
					colorIndex = i;
					break;
				}
			}

            var colorToRemove = colors[colorIndex];
            for(var i = clickColor.length - 1; i >= 0; i--) {
                if(clickColor[i] === colorToRemove) {
                    clickColor.splice(i, 1);
                    clickY.splice(i, 1);
                    clickX.splice(i, 1);
                    clickDrag.splice(i, 1);
					clickWidth.splice(i, 1);
                }
            }
			removeColor(rgbColors[colorIndex], regionContext);
            redraw();
        },
        
        updateHiddenImageData = function(){
            var imageData = regionCanvas.toDataURL("image/png");
            document.getElementById('hidden-image-data').value = imageData;
        },
		
		setLineWidth = function(width){
			lineWidth = width;
		},
				
		setImageRatios = function(height, width){
            aspectRatio = width / height;
            canvasHeight = Math.min(height, window.innerHeight * 0.65);
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

		init = function (targetDivId, image, height, width, answerImg) {
			parentId = targetDivId;
            parentDiv = document.getElementById(parentId);
            
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

            originalImage = image;
			setImageRatios(height, width);
			resourceLoaded();
			if(answerImg){
                drawImage(regionContext, answerImg, function(){
					updateHiddenImageData();
				});
			}
		};

	return {
		init: init,
        setColor : setColor,
        clearColor : clearColor,
        addColor : addColor,
		deleteColor : deleteColor,
		getCurrentColor : getCurrentColor,
		setLineWidth : setLineWidth,
		eraseColor : eraseColor
	};
}());