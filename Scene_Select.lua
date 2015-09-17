--
-- Author: student
-- Date: 2015-06-09 14:40:14
--
local Scene_Select=class("Scene_Select", function ()
	return display.newScene("Scene_Select")
end)
Chapter_Select=require("app.scenes.Chapter_Select")

function Scene_Select:ctor()
    
    --keypad
    -- self:setKeypadEnabled(true)
   -- self:setSwallowTouches(true)
    self:addNodeEventListener(cc.KEYPAD_EVENT,function(event)
        if event.key=="back" then
            if TouchisTime==1 then
                self.message=MessageBox.new()
                self.message:setPosition(cc.p(0,0))
                self:addChild(self.message,3)
                TouchisTime=2
                elseif TouchisTime==2 then
                    if self.message then
                        self.message:removeFromParent()
                    end
                    TouchisTime=1
            end

        end
    end)

    --音乐
    if JuqingMusic==true then
        JuqingMusic=false
        audio.stopMusic()
        audio.playMusic("backmusic.mp3",true)
    end
	-- 返回按钮
	local backBtn=cc.ui.UIPushButton.new({normal="back.png"},{scale9=true})
	backBtn:onButtonClicked(function ()
		display.replaceScene(require("app.scenes.BeginScene").new())
	end)
	backBtn:setPosition(cc.p(50,display.top-50))
	backBtn:setScale(0.15)
	self:addChild(backBtn,1)

	if #PublicData.SCENETABLE==0 then
		local docpath = cc.FileUtils:getInstance():getWritablePath().."data.txt"
		if cc.FileUtils:getInstance():isFileExist(docpath)==false then
			local str = json.encode(Data.SCENE)
			ModifyData.writeToDoc(str)
			PublicData.SCENETABLE = Data.SCENE
		else
			local str = ModifyData.readFromDoc()
			PublicData.SCENETABLE = json.decode(str)
		end
	end


	-- 加载csb
	--cc.FileUtils:getInstance():addSearchPath("res/scene_select")
	self.root=cc.uiloader:load("Scene.csb")
 	:pos(0,0)
    :addTo(self)
    local width=display.width/self.root:getContentSize().width
    local height=display.height/self.root:getContentSize().height
    self.root:setScaleX(width)
    self.root:setScaleY(height)
    
    tb=PublicData.SCENETABLE
    for i=1,#Data.SCENE do
    	local pageView = self.root:getChildByName("PageView_1")
    	local Panel = pageView:getChildByName("Panel_"..i)
    	local btn = Panel:getChildByName("Button_"..i)
    	-- 场景是否锁定
    		if tb[i][13].lock==0 then
    			btn:setEnabled(true)
    			btn:setBright(true)
    			btn:addTouchEventListener(
    				function (ref,type)
    					if type==ccui.TouchEventType.ended then
    						ModifyData.setSceneNumber(i)
    						cc.Director:getInstance():replaceScene(Chapter_Select.new())
    					end
    				end)

    		elseif tb[i][13].lock==1 then
    			btn:setEnabled(false)
    			btn:setBright(false)
    		end
    end

    local pageView = self.root:getChildByName("PageView_1")
    
    pageView:addEventListener(function (ref,type)
    	local index=pageView:getCurPageIndex()
    	if index==3 then
    		pageView:scrollToPage(2)
    	end
    end)
    local leftBtn=self.root:getChildByName("Button_8")
    leftBtn:addTouchEventListener(
    				function (ref,type)
    					if type==ccui.TouchEventType.ended then
    						local pageView = self.root:getChildByName("PageView_1")
							local index=pageView:getCurPageIndex()
    						pageView:scrollToPage(index-1)
    					end
    				end)
    local rightBtn=self.root:getChildByName("Button_9")
    rightBtn:addTouchEventListener(
    				function (ref,type)
    					if type==ccui.TouchEventType.ended then
    						local pageView = self.root:getChildByName("PageView_1")
							local index=pageView:getCurPageIndex()
    						pageView:scrollToPage(index+1)
    					end
    				end)

	end

function Scene_Select:onExit()
	self:removeAllChildren();
end
return Scene_Select