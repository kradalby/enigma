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
        landmarkImage,
        canvasHeight,
        canvasWidth,
        canvas,
        context,
        aspectRatio,
        questionId,
        
        relativeMouseCoordinates = function(event){
            var totalOffsetX = 0;
            var totalOffsetY = 0;
            var canvasX = 0;
            var canvasY = 0;
            var currentElement = document.getElementById("landmark_canvas-" + questionId);

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
        
        enableLandmark = function(targetDivId, image, answerImage, height, width, id){
            console.log(image)
            parentId = targetDivId;
            parentDiv = document.getElementById(parentId);
            questionId = id;
            
            // Create canvas
            canvas = document.createElement('canvas');
            canvas.id = "landmark_canvas-" + questionId;
            parentDiv.appendChild(canvas);
            context = canvas.getContext('2d');
            
            // Create hidden answer field
            hiddenAnswerField = document.createElement("input");
            hiddenAnswerField.setAttribute("type", "hidden");
            hiddenAnswerField.setAttribute("name", "landmark_question-" + questionId);
            hiddenAnswerField.setAttribute("value", "{}");
            parentDiv.appendChild(hiddenAnswerField);

            // Register other necessities
            originalImage = image;
            landmarkImage = answerImage;
            setImageRatios(height, width);
            
            registerColoredRegions(landmarkImage, function(){
                drawImage(originalImage);
            });
            
            updateHiddenAnswerOnMouseUp();
            drawXOnMouseUp();
        };

    return {
		enableLandmark: enableLandmark
	};
});
