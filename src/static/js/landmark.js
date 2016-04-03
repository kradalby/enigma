var coloredRegions = [];
var distanceToColorThreshold = 0;
var origImg;

//processImage("img/1_solution.png", 681, 618);
function landmark(originalImage, landmarkImage, width, height){
    origImg = originalImage;
    processImage(landmarkImage, width, height, function(){
        drawImage(originalImage, width, height);
    })
}

function drawImage(originalImage, width, height, callback){
    var canvas = document.getElementById('viewport'),
    context = canvas.getContext('2d');

    var image = new Image();
    image.src = originalImage;
    image.onload = function(){
        context.drawImage(image, 0, 0, width, height);
        if(callback){
            callback();
        }
    }
}

function processImage(imgSrc, width, height, callback){
    var canvas = document.getElementById('viewport'),
    context = canvas.getContext('2d');

    var image = new Image();
    image.src = imgSrc;
    image.onload = function(){
        context.drawImage(image, 0, 0, width, height);
        var imageData = context.getImageData(0,0,width,height);
        var pixelsAndColors = getColorsAndPositions(imageData, width);
        DetectRegions(pixelsAndColors); 
        AddMouseOverListener();
        ClearCanvas(canvas);
        drawXOnMouseUp();
        callback();
    }
}

function ClearCanvas(canvas){
    context = canvas.getContext('2d');
    context.clearRect(0, 0, canvas.width, canvas.height);
}

function DetectRegions(pixelsAndColors){
    var colorTable = pixelsAndColors.table();
    for (var color in colorTable) {
        if (colorTable.hasOwnProperty(color)) {
            coloredRegions.push({
                color: color,
                points: colorTable[color]
            });
        }
    }
}

function getColorsAndPositions(imageData, width)
{
    var data = imageData.data;
    var colors = new HashTable();

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
                x: Math.floor((i / 4) % width), 
                y: Math.floor((i / 4) / width)
            });
        }
    }
    
    return colors;
}

function AddMouseOverListener(){
    document.getElementById('viewport').addEventListener("mouseup", mouseUp, false);
    function mouseUp(e){
        for(var i = 0; i < coloredRegions.length; i++){
            var region = coloredRegions[i];
            if(IsInsideColorRegion(region.points, event.offsetX, event.offsetY) ||
               IsCloseToColorRegion(region.points, event.offsetX, event.offsetY, distanceToColorThreshold)){
                $("#landmark_answer").val(region.color);
                return;
            }
        }
        
        $("#landmark_answer").val("{}");
    };
}

function IsInsideColorRegion(points, x, y){
    var existPointToLeft = false,
        existPointToRight = false,
        existPointAbove = false,
        existPointBelow = false;
    
    for(var i = 0; i < points.length; i++){
        var point = points[i];
        if(!existPointAbove && point.x === x && point.y >= y){
            existPointAbove = true;
        }
        if(!existPointBelow && point.x === x && point.y <= y){
            existPointBelow = true;
        }
        if(!existPointToLeft && point.x >= x && point.y === y){
            existPointToLeft = true;
        }
        if(!existPointToRight && point.x <= x && point.y === y){
            existPointToRight = true;
        }
    }
    
    return existPointToLeft && existPointAbove && existPointBelow && existPointToRight;
}

function IsCloseToColorRegion(points, x, y, threshold){
    for(var i = 0; i < points.length; i++){
        var point = points[i];
        var dx = point.x,
            dy = point.y;
        var distance = Math.sqrt(Math.pow(x-dx, 2) + Math.pow(y-dy, 2));
        if(distance <= threshold){
            console.log("Close to color region!!");
            return true;
        }
    }
    
    return false;
}

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
 * Draw x on click
 */

function drawXOnMouseUp(){
    var canvas = document.getElementById('viewport');
    var ctx = canvas.getContext("2d");

    var mouseX, mouseY;

    canvas.addEventListener("mouseup", mouseUp, false);

    function drawX(x, y) {
        ctx.beginPath();
        ctx.strokeStyle="#FF0000";
        
        ctx.moveTo(x - 10, y - 10);
        ctx.lineTo(x + 10, y + 10);
        ctx.stroke();

        ctx.moveTo(x + 10, y - 10);
        ctx.lineTo(x - 10, y + 10);
        ctx.stroke();
    }

    function mouseUp(e) {
        mouseX = e.pageX - canvas.offsetLeft;
        mouseY = e.pageY - canvas.offsetTop;
        
        ClearCanvas(canvas);
        drawImage(origImg, 681, 618, function(){
            drawX(mouseX, mouseY);
        });
    }
}