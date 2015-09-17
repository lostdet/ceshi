 --
-- Author: student
-- Date: 2015-06-14 16:17:18
--
--开启时间调度
local scheduler = require(cc.PACKAGE_NAME..".scheduler")
GamePlay = class("GamePlay", function ()
	return display.newScene("GamePlay")
end)
TitleMap=require("app.Class.TitleMap")
setTotal=require("app.Class.setTotal")
Loser=require("app.Class.Loser")
Success=require("app.Class.Success")
DaojuLayer=require("app.Class.DaojuLayer")
TouchLayer=require("app.Class.TouchLayer")
Progress=require("app.Class.Progress")
Mask=require("app.Class.Mask")
function GamePlay:ctor()
	cc.Director:getInstance():resume()
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

	
	Data.PathPoint={}
	Data.Tower={}
	Data.mask={}
	Data.Bullet={}
	Data.point={}

	self.jinbi = true -- 判断金币数目不够时，不可点击
	-- 通过个数
	self.Tongguogeshu=0
	self.fashe= true
	--self.dd=true
	m=ModifyData.getSceneNumber()
	n=ModifyData.getChapterNumber()
	--添加地图
	self._map = TitleMap.new(n)
	self:addChild(self._map)
	self:setNobitPos()

	--添加total
	self.total=setTotal.new()
	self:addChild(self.total,2)

	-- 金币
	ModifyData.money = Data.SCENE[m][n].Money
	self.livemask = {} -- 活着的怪物表
	
	-- 触摸层
	self:touches()
	
	self:handle() --攻击
	
	--怪物
	self:CreateMaskGroup()
	self.attackCount = 0

end

function GamePlay:setNobitPos()
	--设置大雄的位置
	--添加大雄
	local tb = Data.getPathPoint()
	local Nobittable = tb[#tb]
	self._NobitPos = cc.p(Nobittable.x,Nobittable.y) 

	--d大雄的图片
	local png = "da.png"
	local plist = "da.plist"
	display.addSpriteFrames(plist,png)
	self._Nobit = display.newSprite("#d_1.png")
	self._Nobit:pos(Nobittable.x,Nobittable.y)
	self._Nobit:setScale(1.6)
	local frames = display.newFrames("d_%d.png",1,12)
	local animation = display.newAnimation(frames,0.1)
	self._Nobit:playAnimationForever(animation,0.1)
	self:addChild(self._Nobit,1)

end

function GamePlay:touches()
	self._Touchlayer = TouchLayer.new({
		funcB = function(x)
			--print("TouchBegin")
			self.EndPoint = x --获得触摸点
			self:juegeCanCreatTower()
		end,
		funcE = function(event)
			-- if self.git>0 or self.git1>0 or self.jinbi == false then
			-- 	self.stoppic:removeFromParent()
			-- end
			if self.stoppicTag==1  then
				self.stoppic:removeFromParent()
				self.stoppicTag=0
			end
			 
		end
		})
	self._Touchlayer:addTo(self)
end

function GamePlay:handle()
	
	self.handle=scheduler.scheduleGlobal(function () ---时间调度来测试怪物和塔的距离<射程 --包括跑的旋转
	
			--print(ModifyData.money.."##############################")
			
		for k1,v1 in pairs(Data.mask) do--怪物
		
			for k2,v2 in pairs(Data.Tower) do--塔
			
				local p = math.sqrt((v1:getPositionX()-v2:getPositionX())*(v1:getPositionX()-v2:getPositionX())+(v1:getPositionY()-v2:getPositionY())*(v1:getPositionY()-v2:getPositionY()))
				
				
				if p<v2.scoper then
					--攻击 --发射子弹
					--print("v2.scoper"..v2.scoper)
					--添加进表
					self:attacks(v2,v1)

				else
				--不攻击
				
				end
				self:TestCollided(v1)--参数为怪物
				
				if ModifyData.money - v2.money < 0 then
					self.jinbi = false
				--print("1111111111111111")
				else
					self.jinbi = true
				end
			end
		end
		
	end,0.1)
	
end
function GamePlay:attacks(v1,v) --zidan 和怪物
		--发射子弹
		if v == nil then
			return
		end
		if self.attackCount == 0 then
		--print(tolua.type(self.leftMask))
			local Bbullet = display.newSprite(v1._towerName.."_zidan.png")
			Bbullet:pos(v1._x,v1._y)
		    Bbullet.isMove = true
		    Bbullet:setAnchorPoint(cc.p(0.6,0.5))
		    Bbullet.demage = v1.demage
		    --Bbullet:addTo(self,1) 
		    self.attackCount = 1
		    self:addChild(Bbullet)
		    local move = cc.MoveTo:create(0.1, cc.p(v:getPositionX(),v:getPositionY()))
		    local delay=cc.DelayTime:create(0.05)
		    local fun0 = cc.CallFunc:create(function ()
						self.attackCount = 0
						Bbullet.isMove = false

			end)
			seq = cc.Sequence:create(move,delay,fun0)
	   	 	Bbullet:runAction(seq)
	    	Data.Bullet[#Data.Bullet+1]=Bbullet--?
		end
	    --大炮旋转
	    if v1.isRote == true then 
			--大炮旋转
			local rol = cc.RotateTo:create(0.2,self:angle(v1,v))--v1 为炮，v为怪物
			v1:runAction(rol)
		
		end	
end


function GamePlay:TestCollided(v)--检测子弹和怪物的碰撞 参数为怪物
	if v ==nil then
		return
	end
	for k2,v2 in pairs(Data.Bullet) do--子弹
		
			
		local rect0 = self:newRect(v2)
		local rect1 = self:newRect(v) --怪物
			
		if cc.rectIntersectsRect(rect0,rect1) then--怪物是否和炮弹碰撞
			-- 怪物减血
			 v.hp = v.hp-v2.demage
			-- 血量条
			 v.bar:setProgress(v.hp/v.Allhp*100)

			 v2.isMove = false

		end
		if  v.hp<0  then --如果怪物体力hp<0
			v.islive = false

			
			
		end
		
	end
end

function GamePlay:newRect(v) --碰撞检测调用
	
	if  v==nil then
			
			return
	end

		local size = v:getContentSize()
		local x = v:getPositionX()
		local y = v:getPositionY()
		local rect = cc.rect(x-size.width/2, y-size.height/2, size.width, size.height)
		return rect
	
	

end




function GamePlay:angle(v1,v)--vv1 为炮，v为怪物
	local x = v1:getPositionX()-v:getPositionX()
    local y = v1:getPositionY()-v:getPositionY()
    if x>0 then
        if y>0 then
            return math.atan(x/y)*180/math.pi
            else
            return math.atan(x/y)*180/math.pi+180
        end
    else
        if y>0 then
            return math.atan(x/y)*180/math.pi
            else
            return math.atan(x/y)*180/math.pi-180
        end    
    end
end



function GamePlay:juegeCanCreatTower()
 	--判断是否考虑以再点击的位置添加炮塔
 	-- 转换为瓦片坐标
 	local a = self._map._tileMap:getBoundingBox()
 	self.titX = math.ceil(self.EndPoint.x/80)-1
 	self.titY =8-math.ceil(self.EndPoint.y/80)
 	--触摸到层不可以点
 	--获取到地图上面的块 的属性
 	self.map_Notouch = self._map._tileMap:getLayer("NoTouch")
 	self.can_touch = self._map._tileMap:getLayer("canTouch")
 	self.notouch = self._map._tileMap:getLayer("notouch")--上面的total
 	self.git = self.map_Notouch:getTileGIDAt(cc.p(self.titX,self.titY))
 	self.git1 = self.can_touch:getTileGIDAt(cc.p(self.titX,self.titY))
 	self.git2 = self.notouch:getTileGIDAt(cc.p(self.titX,self.titY))
 	
 	local i =0 --判断是否可以在重复的位置添加炮

 	if self.git2>0 then --使最上面的total不可以点
 		i=2
 	else
 		i=0
 	end


 	if self.git>0 or self.git1>0 or self.jinbi == false  then
 		--self.prop = self._map._tileMap:getPropertiesForGID(self.git)
 		--if self.prop.value =="1"then--

 			self.stoppic = display.newSprite("Stop.png") 
 			self.stoppic:pos(self.EndPoint.x, self.EndPoint.y)
 			self:addChild(self.stoppic)
 			self.stoppicTag=1
 		--end

	else--添加炮
 		self.s = self._map._tileMap:getTileSize().width
 		self.newPoint_x = math.ceil(self.EndPoint.x/self.s)*self.s-self.s/2--瓦片 
 		self.newPoint_y = math.ceil(self.EndPoint.y/self.s)*self.s-self.s/2
 		
 		for k,v in pairs(Data.point) do
 			if  self.newPoint_x == v.x and self.newPoint_y==v.y then
				i=1
			end
		end
	
		if i == 0  then
			self.layer_daoju = DaojuLayer.new(self.newPoint_x,self.newPoint_y)
			self:addChild(self.layer_daoju)	
 		elseif i==1 then
 			
 			--添加升级层 --移除
 			self.menu_daoju = DaojuLayer.new(self.newPoint_x,self.newPoint_y)
			self:addChild(self.layer_daoju)	

 		end

	end
		
 end


function GamePlay:CreateMaskGroup()
	local sceneNum=ModifyData.getSceneNumber()
	local chapterNum=ModifyData.getChapterNumber()
	-- 获取到每关卡怪物的种类
	self.maskTb=Data.MaskDecorateTab[sceneNum][chapterNum]
	-- 获取到每关卡怪物总波数
	local n=#Data.MaskDecorateTab[sceneNum][chapterNum]
	-- 从第一波到最后一波遍历每关卡的所有怪物
	-- 每20秒生成一波怪物
	self.i=1 --波数 
	-- 第一波怪物
	local MaskType = self.maskTb[self.i][1]
			self.MaskName = MaskType.maskName

			-- 获取第以波怪物的总个数
			self.MaskNum = self.maskTb[self.i][2]
			self:CreateMask()
			
	-- 从第二波开始怪物
	self.handle1=scheduler.scheduleGlobal(function ()
		if self.i<=n then
			self.total.BossNum:setString("第 "..self.i.."/ "..n.." ".."波 ")
			-- 获取第i波怪物的种类
			local MaskType = self.maskTb[self.i][1]
			self.MaskName = MaskType.maskName
			-- 获取第i波怪物的总个数
			self.MaskNum = self.maskTb[self.i][2]
			self:CreateMask()
		else
			scheduler.unscheduleGlobal(self.handle1)
		end

	end,15)

	self.handle3=scheduler.scheduleGlobal(function ()
		-- 判断失败
			if self.Tongguogeshu>=10 then
				audio.playSound("loser.mp3")
				local loser=Loser.new()
				self:addChild(loser,2)

				cc.Director:getInstance():pause()
			end
		-- 判断成功
		if self.i==#Data.MaskDecorateTab[sceneNum][chapterNum]+1 then --怪物第10波出来完
			print(self.i)
			for i,v in pairs(Data.mask) do
				print(i,v)
			end
			if #Data.mask==0 and self.Tongguogeshu<10 then
				audio.playSound("success.mp3")
				local success=Success.new()
				self:addChild(success,2)
				cc.Director:getInstance():pause()
			end
		end


		-- 怪物走到最后，移除
			for i,v in pairs(Data.mask) do
				local pab = Data.getPathPoint()
				if v:getPositionX()==pab[#pab].x and v:getPositionY()==pab[#pab].y then
					v:removeFromParent()
					table.remove(Data.mask,i)
				end

				if v.islive == false then
				ModifyData.money = ModifyData.money + v.mkMoney
				v:removeSelf()
		 		table.remove(Data.mask,i)
				end	
			end
		-- 金币
			local m=ModifyData.getSceneNumber()
			local n=ModifyData.getChapterNumber()
			self.total.GoldNum:setString(ModifyData.money)

		-- 移除子弹
		for k1,v1 in pairs(Data.Bullet) do
			if v1.isMove == false then
				audio.playSound("4057.mp3")
				v1:stopAllActions()
				self.attackCount = 0
				table.remove(Data.Bullet,k1)
				v1:removeSelf()
			end
		end

		end,0.01)

end


function GamePlay:CreateMask()
	self.j=1 -- 个数
	--第一个怪物
	self:CreateMaskAndMove()
		self.j=self.j+1
	-- 从第二个起，每秒生成一个怪物
	self.handle2=scheduler.scheduleGlobal(function ()
		if self.j<=self.MaskNum then
			self:CreateMaskAndMove()
			self.j=self.j+1
		else
			self.i=self.i+1
			scheduler.unscheduleGlobal(self.handle2)
		end
	end,1)
	
end
function GamePlay:CreateMaskAndMove()
	
	local msk=Mask.new(self.i)
	local tbb = Data.getPathPoint()
	

	-- table.insert(Data.mask,msk)--插入到怪物表中
	Data.mask[#Data.mask+1]=msk
		self.ta={}
		local action1 = cc.CallFunc:create(function ()
			local chuxian = tbb[1]
			local png = "chuxian.png"
			local plist = "chuxian.plist"
			display.addSpriteFrames(plist,png)
			self.chuxian = display.newSprite("#1_1.png")
			self.chuxian:pos(chuxian.x+5,chuxian.y-20)
			self.chuxian:setScale(0.4)
			local  chuxianframe = display.newFrames("1_%d.png",1,7)
			local animation = display.newAnimation(chuxianframe,0.05)
			local anima = cc.Animate:create(animation) 
			self:addChild(self.chuxian)
			local removechuxian = cc.CallFunc:create(function ()
					self.chuxian:removeSelf()
			end)
			local chuxianseq = cc.Sequence:create(anima,removechuxian)
			self.chuxian:runAction(chuxianseq)--执行出现动作
			end)
		self.ta[#self.ta+1]=action1

		for k=2,#Data.getPathPoint() do
			
			local pointTab = Data.getPathPoint()
			--匀速运动
			local dis=math.sqrt(((pointTab[k].x-pointTab[k-1].x)*(pointTab[k].x-pointTab[k-1].x))+((pointTab[k].y-pointTab[k-1].y)*(pointTab[k].y-pointTab[k-1].y)))
			local t=dis/msk.maskSpeed -- 速度
			local move1 = cc.MoveTo:create(t,pointTab[k])
			self.ta[#self.ta+1]=move1
		end
		local action = cc.CallFunc:create(function ( )
				local png = "xiaoshi.png"
			    local plist = "xiaoshi.plist"
			    display.addSpriteFrames(plist,png)
			    local xiaoshi = tbb[#tbb]
			    self.Axiaoshi = display.newSprite("#11-1.png")
			    self.Axiaoshi:pos(xiaoshi.x,xiaoshi.y) 
				local xiaoshiframe = display.newFrames("11-%d.png",1,7)
				local animation = display.newAnimation(xiaoshiframe,0.04)
				local animate = cc.Animate:create(animation)
				
				self:addChild(self.Axiaoshi)
				local removeaction = cc.CallFunc:create(function ()
					self.Axiaoshi:removeSelf()
				end)
				local xiaoshiseq = cc.Sequence:create(animate,removeaction)
				self.Axiaoshi:runAction(xiaoshiseq)--执行消失动作
		end)
		self.ta[#self.ta+1]=action
		local re=cc.CallFunc:create(function ()
			-- 走到最后时候消失
			msk:removeSelf()
			self.Tongguogeshu=self.Tongguogeshu+1
			table.remove(Data.mask,1)
		end)
		self.ta[#self.ta+1]=re
		local seq = cc.Sequence:create(self.ta)
		msk:setPosition(cc.p(Data.getPathPoint()[1].x,Data.getPathPoint()[1].y))
		msk:addTo(self)
		msk:runAction(seq)
		

end


function GamePlay:onExit()
	cc.Director:getInstance():resume()
	if self.handle1 then
		scheduler.unscheduleGlobal(self.handle1)
	end
	if self.handle2 then
		scheduler.unscheduleGlobal(self.handle2)
	end
	if self.handle3  then
		scheduler.unscheduleGlobal(self.handle3)
	end
	if self.handle then
		scheduler.unscheduleGlobal(self.handle)
	end
	--返回一倍速度
	cc.Director:getInstance():getScheduler():setTimeScale(1)
end
return GamePlay