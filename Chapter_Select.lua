--
-- Author: zhenghang
-- Date: 2015-06-15 14:09:05
--
local Chapter_Select = class("Chapter_Select", function()
    return display.newScene("Chapter_Select")
end)

GamePlay=require("app.scenes.GamePlay")
function Chapter_Select:ctor()
	--keypad
	self:setKeypadEnabled(true)
	self:addNodeEventListener(cc.KEYPAD_EVENT,function(event)
		if event.key=="back" then
			if TouchisTime==1 then
				for i=1,12 do
					local btn= self.node:getChildByName("Button_"..i)
					btn:setTouchEnabled(false)
				end
				self.message=MessageBox.new()
				self.message:setPosition(cc.p(0,0))
				self:addChild(self.message,3)
				ChapterSelect=1
				TouchisTime=2
			elseif TouchisTime==2 then
				for i=1,12 do
					local btn= self.node:getChildByName("Button_"..i)
					btn:setTouchEnabled(true)
				end
				if self.message then
					self.message:removeFromParent()
				end
				TouchisTime=1
				ChapterSelect=2	
			end

		end
	end)
	
	--返回到选择场景的按钮
	local backBtn=cc.ui.UIPushButton.new({normal="back2.png"},{scale9=true})
	backBtn:onButtonClicked(function ()
		display.replaceScene(Scene_Select.new())
	end)
	backBtn:setScale(0.15)
	backBtn:setPosition(cc.p(50,display.top-50))
	self:addChild(backBtn,1)
	-- 加载csb
	 local sceneNum=ModifyData.getSceneNumber()
	if sceneNum==1 then

		--cc.FileUtils:getInstance():addSearchPath("res/chapter_select1")
		self.node=cc.uiloader:load("Scene1.csb")
		self.node:pos(0, 0)
		local width=display.width/self.node:getContentSize().width
    	local height=display.height/self.node:getContentSize().height
    	self.node:setScaleX(width)
    	self.node:setScaleY(height)
		self:addChild(self.node)
	elseif sceneNum==2 then
		--cc.FileUtils:getInstance():addSearchPath("res/chapter_select2")
		self.node=cc.uiloader:load("Scene2.csb")
		self.node:pos(0, 0)
		local width=display.width/self.node:getContentSize().width
    	local height=display.height/self.node:getContentSize().height
    	self.node:setScaleX(width)
    	self.node:setScaleY(height)
		self:addChild(self.node)
	elseif sceneNum==3 then
		--cc.FileUtils:getInstance():addSearchPath("res/chapter_select3")
		self.node=cc.uiloader:load("Scene3.csb")
		self.node:pos(0, 0)
		local width=display.width/self.node:getContentSize().width
    	local height=display.height/self.node:getContentSize().height
    	self.node:setScaleX(width)
    	self.node:setScaleY(height)
		self:addChild(self.node)
		
	elseif sceneNum==4 then
		-- cc.FileUtils:getInstance():addSearchPath("res/scene_select/chapter_select4")
		-- self.node=cc.uiloader:load("Scene4.csb")
		-- self.node:pos(0, 0)
		-- self:addChild(self.node)
		-- local width=display.width/self.node:getContentSize().width
  --   	local height=display.height/self.node:getContentSize().height
  --   	self.node:setScaleX(width)
  --   	self.node:setScaleY(height)
 end
	

	tb=PublicData.SCENETABLE
	for m=1,12 do
		local btn= self.node:getChildByName("Button_"..m)
		if tb[sceneNum][m].lock==0 then
			btn:setEnabled(true)
			btn:setBright(true)
			btn:addTouchEventListener(function (ref,type)
				if type==ccui.TouchEventType.ended then
				
					ModifyData.setChapterNumber(m)
					display.replaceScene(GamePlay.new())

				end
			end)
		elseif tb[sceneNum][m].lock==1 then
			btn:setEnabled(false)
			btn:setBright(false)
		end
		
	end
	

	
end
return Chapter_Select
