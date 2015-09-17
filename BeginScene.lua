local BeginScene=class("BeginScene", function()
	return display.newScene("BeginScene")
end)
--修改了数据
--真的修改了数据
MessageBox=require("app.Class.MessageBox")
function BeginScene:ctor()
	
	BeginScene.isPlayMusic=true
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(true)

	self:init()
	
end

function BeginScene:init()

	--keypad
	self:setKeypadEnabled(true)
	self:addNodeEventListener(cc.KEYPAD_EVENT,function(event)
		if event.key=="back" then
			if TouchisTime==1 then
				cc.Director:getInstance():pause()
				self.message=MessageBox.new()
				self.message:setPosition(cc.p(0,0))
				self:addChild(self.message,3)
				TouchisTime=2
				elseif TouchisTime==2 then
					if self.message then
						cc.Director:getInstance():resume()
						self.message:removeFromParent()
					end
					TouchisTime=1
			end

		end
	end)


	
	local bg=display.newSprite("begin.png")
	local scaleX=display.width/bg:getContentSize().width
	local scaleY=display.height/bg:getContentSize().height
	bg:setScaleX(scaleX)
	bg:setScaleY(scaleY)
	bg:setPosition(cc.p(display.cx,display.cy))
	self:addChild(bg)
	--播放音乐
	if BeginScene.isPlayMusic then
		audio.playMusic("backmusic.mp3",true)
		audio.setMusicVolume(0.5)
	end
	self.setButton=cc.ui.UIPushButton.new({normal="help.png",pressed="help.png"},{scale9=true})
	:onButtonClicked(function(event)
		self:setBtn()
	end)
	:scale(0.8)
	:pos(display.right-80, display.top-100)
	:addTo(self)
-- yiwen
	self.helpButton=cc.ui.UIPushButton.new({normal="yiwen.png",pressed="yiwen.png"},{scale9=true})
	:onButtonClicked(function(event)
		self:yiwen()
	end)
	:scale(0.8)
	:pos(display.right-80, display.top-190)
	:addTo(self)

--开始
	self.starButton=cc.ui.UIPushButton.new({
		normal="play.png",pressed="play2.png"},{scale9=true})
		:onButtonClicked(function()
			cc.Director:getInstance():replaceScene(require("app.scenes.Scene_Select").new())--界面跳转
			end)
		:pos(display.cx,display.cy-170)
		:addTo(self)

	end
function BeginScene:setBtn()
	self._set=display.newLayer()
	local bg=display.newSprite("succeed2.png")
	bg:setPosition(cc.p(display.cx,display.cy-200))
	bg:setScale(0.6)
	self._set:addChild(bg,2)
	transition.moveTo(bg,{x=display.cx,y=display.cy,time=0.8})
	self:addChild(self._set)

	--音乐开关
	local music=display.newSprite("music.png")
	:pos(bg:getContentSize().width/2-130,bg:getContentSize().height/2+100)
	:addTo(bg)

	cc.ui.UICheckBoxButton.new({on = "music1.png",off = "music2.png"})
        :pos(bg:getContentSize().width/2+70,bg:getContentSize().height/2+100)
        :setButtonSelected(BeginScene.isPlayMusic)
        :onButtonStateChanged(function(event)	
        	if event.state == "on" then
        		BeginScene.isPlayMusic = true
        		audio.playMusic("backmusic.mp3",true)
				audio.setMusicVolume(0.5)
			elseif  event.state == "off" then
				BeginScene.isPlayMusic = false
				audio.stopMusic()
			end
        	end)
        :addTo(bg,4)

    --音效开关
    local yinxiao=display.newSprite("yinxiao.png")
	:pos(bg:getContentSize().width/2-130,bg:getContentSize().height/2)
	:addTo(bg)

	cc.ui.UICheckBoxButton.new({on = "yinxiao1.png",off = "yinxiao2.png"})
		:pos(bg:getContentSize().width/2+70,bg:getContentSize().height/2)
        
        :setButtonSelected(BeginScene.isPlaySound)
        :onButtonStateChanged(function(event)
        	if event.state == "on" then
        		BeginScene.isPlaySound = true
				audio.playSound("yinxiao.wav", false)
			elseif  event.state == "off" then
				BeginScene.isPlaySound = false
				audio.stopAllSounds()
			end
			end)
        :addTo(bg,4)


	local btn=cc.ui.UIPushButton.new({normal="ok.png"},{scale9=true})
	:addTo(bg)
	btn:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height/2-120))
	
	btn:onButtonClicked(function()
		self._set:removeFromParent()
		
	end)

end

function BeginScene:yiwen()
	self._set=display.newLayer()
	local bg=display.newSprite("gonggao.png")
	bg:setPosition(cc.p(display.cx,display.cy-200))
	bg:setScale(0.6)
	self._set:addChild(bg,2)
	transition.moveTo(bg,{x=display.cx,y=display.cy,time=0.8})
	self:addChild(self._set)


	local btn=cc.ui.UIPushButton.new({normal="ok.png"},{scale9=true})
	:addTo(bg)
	btn:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height/2-170))
	btn:setScale(0.7)
	btn:onButtonClicked(function()
		self._set:removeFromParent()
		
	end)

end
return BeginScene
