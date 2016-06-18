local photoLibPlus = require "plugin.photoLibPlus"
local lfs = require( "lfs" )
local widget = require "widget" 
local json = require "json"

native.showPopup( "requestAppPermission", {appPermission = "android.permission.READ_EXTERNAL_STORAGE", urgency = "Critical", } )


local allPhotos
local thumbnailsCreated = false;

local function copyImages()
    if not allPhotos then
        print( "WARNING: You must call listPhotos() before calling copyImages()" )
        return
    end
	local tempDirPath = system.pathForFile("", system.TemporaryDirectory)
	local images = 0
	for photoID, photoParams in pairs(allPhotos) do
		print("Processing Image " .. photoID)
		if images == 30 then
			break
		end
		photoLibPlus.createThumbnail(photoID, {name = "thumbnail--"..tostring(photoID)..".png", path = tempDirPath, width = 512, height = 384, contentMode = "fit"})
		photoLibPlus.copyImage(photoParams["_data"], "image--"..tostring(photoID)..".png", tempDirPath)
	    images = images+1
	end
    thumbnailsCreated = true
	for file in lfs.dir( tempDirPath ) do
        -- File is the current file or directory name
        print( "Found file: " .. file )
    end
end

local function displayThumbnails()
	local images = 0
    if not thumbnailsCreated then
        print( "WARNING: You must call copyImages() before calling displayThumbnails()" )
        return
    end
	for photoID, photoParams in pairs(allPhotos) do
		if (images == 24) then
			break
		end
		local image = display.newImage("thumbnail--"..tostring(photoID)..".png", system.TemporaryDirectory)
		image.xScale = 0.125
		image.yScale = 0.125
		image.x = display.contentWidth/5 * (images%4 + 1)
		image.y = display.contentHeight/7 * ((images - images%4)/4 + 1)
	    images = images + 1
	end
end


local listAllPhotosBtn = widget.newButton{ x = display.contentWidth/2, y = display.contentHeight/4, width = 200, height = 60, label = "List all photos", onRelease = function() allPhotos = photoLibPlus.listImages(); print(json.prettify(allPhotos)) end}
local copyPhotosBtn = widget.newButton{ x = display.contentWidth/2, y = display.contentHeight/4*2, width = 200, height = 60, label = "Copy images", onRelease = copyImages}
local showTumbnails = widget.newButton{ x = display.contentWidth/2, y = display.contentHeight/4*3, width = 200, height = 60, label = "Show thumbnails", onRelease = displayThumbnails}


 