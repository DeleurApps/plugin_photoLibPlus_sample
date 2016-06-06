local photoLibPlus = require "plugin.photoLibPlus"
local lfs = require( "lfs" )
local widget = require "widget" 

local function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end


native.showPopup( "requestAppPermission", {appPermission = "android.permission.READ_EXTERNAL_STORAGE", urgency = "Critical", } )
native.showPopup( "requestAppPermission", {appPermission = "android.permission.WRITE_EXTERNAL_STORAGE", urgency = "Critical", } )


local allPhotos

local function copyImages()
	local tempDirPath = system.pathForFile("", system.TemporaryDirectory)
	local images = 0
	for photoID, photoParams in pairs(allPhotos) do
		if images == 30 then
			break
		end
	    local thumbnail = photoLibPlus.createThumbnail(photoID)

	    photoLibPlus.copyImage(photoParams["_data"], "image--"..tostring(photoID)..".png", tempDirPath)
	    photoLibPlus.copyImage(thumbnail["_data"], "thumbnail--"..tostring(photoID)..".png", tempDirPath)
	    images = images+1
	end
	for file in lfs.dir( tempDirPath ) do
    -- File is the current file or directory name
    print( "Found file: " .. file )
end
end

local function displayThumbnails()
	local images = 0
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


local listAllPhotosBtn = widget.newButton{ x = display.contentWidth/2, y = display.contentHeight/4, width = 200, height = 60, label = "List all photos", onRelease = function() allPhotos = photoLibPlus.listImages(); print_r(allPhotos) end}
local copyPhotosBtn = widget.newButton{ x = display.contentWidth/2, y = display.contentHeight/4*2, width = 200, height = 60, label = "Copy images", onRelease = copyImages}
local showTumbnails = widget.newButton{ x = display.contentWidth/2, y = display.contentHeight/4*3, width = 200, height = 60, label = "Show thumbnails", onRelease = displayThumbnails}


--local thumbnails = photoLibPlus.listAvailibleThumbnails()
--print_r(thumbnails)
 