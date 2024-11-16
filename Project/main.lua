function NewObject(x, y, vx, vy, sz)
	local object={
		X=x;
		Y=y;
		VelocityX=vx;
		VelocityY=vy;
		Size=sz;
	}
	return object
end

function NewPlayer(x, y, vx, vy, spd, sz)
	local player={
		X=x;
		Y=y;
		VelocityX=vx;
		VelocityY=vy;
		Speed=spd;
		Size=sz
	}
	return player
end

Rock={}
PointDraws={}
Numbers={}
cat=0
function love.load()
	RedShip=love.graphics.newImage('RedShip.png')
	BlueShip=love.graphics.newImage('BlueShip.png')
	GO=love.graphics.newImage('GameOver.png')
	Numbers[0]=love.graphics.newImage('Number0.png')
	Numbers[1]=love.graphics.newImage('Number1.png')
	Numbers[2]=love.graphics.newImage('Number2.png')
	Numbers[3]=love.graphics.newImage('Number3.png')
	Numbers[4]=love.graphics.newImage('Number4.png')
	Numbers[5]=love.graphics.newImage('Number5.png')
	Numbers[6]=love.graphics.newImage('Number6.png')
	Numbers[7]=love.graphics.newImage('Number7.png')
	Numbers[8]=love.graphics.newImage('Number8.png')
	Numbers[9]=love.graphics.newImage('Number9.png')
	Rock[1]=love.graphics.newImage('Asteroid25.png')
	Rock[2]=love.graphics.newImage('Asteroid50.png')
	Rock[3]=love.graphics.newImage('Asteroid75.png')
	Rock[4]=love.graphics.newImage('Asteroid100.png')
	Rock[5]=love.graphics.newImage('Asteroid125.png')
	Explosion=love.graphics.newImage('Explosion.png')
	PointDraws[1]=love.graphics.newImage('1Point.png')
	PointDraws[2]=love.graphics.newImage('2Point.png')
	PointDraws[3]=love.graphics.newImage('3Point.png')
	PointDraws[4]=love.graphics.newImage('4Point.png')
	PointDraws[5]=love.graphics.newImage('5Point.png')
	
	love.window.setMode(1280, 720, {resizable=false})
	love.window.setTitle('String Theory: In Space!!!')
	Setup()
end

function love.update(dt)
	if Alive==1 then
		Input(dt)
		MovePlayers()
		MoveAsteroids(dt)
		DeathCheck()
		Delete(1)
		CreateAsteroids()
		
		Players[1].VelocityX, Players[1].VelocityY, Players[2].VelocityX, Players[2].VelocityY=Pull()
	else
		GameOver()
	end
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	local dist=Distance(Players[1].X, Players[1].Y, Players[2].X, Players[2].Y)
	--love.graphics.draw(BG, 0, 0, 0, 1, 1, 0, 0, 0, 0	)
	--love.graphics.translate(-(Players[1].X+Players[2].X)/2+640, -(Players[1].Y+Players[2].Y)/2+360)
	love.graphics.setColor(0, dist, 0)
	love.graphics.line(Players[1].X, Players[1].Y, Players[2].X, Players[2].Y)
	love.graphics.setColor(255, 255, 255)
	--[[
	love.graphics.circle('fill', Players[1].X, Players[1].Y, Players[1].Size)
	love.graphics.setColor(255, 255, 255)
	love.graphics.circle('fill', Players[2].X, Players[2].Y, Players[2].Size)
	--]]
	love.graphics.draw(RedShip, Players[1].X-25, Players[1].Y-25, 0, 1, 1, 0, 0, 0, 0)
	love.graphics.draw(BlueShip, Players[2].X-25, Players[2].Y-25, 0, 1, 1, 0, 0, 0, 0)
	for i=1, table.getn(Asteroids), 1 do
		--love.graphics.circle('fill', Asteroids[i].X, Asteroids[i].Y, Asteroids[i].Size)
		love.graphics.draw(Rock[Asteroids[i].Size/12.5], Asteroids[i].X-Asteroids[i].Size, Asteroids[i].Y-Asteroids[i].Size, 0, 1, 1, 0, 0, 0, 0)
	end
	DrawPoints()
	if Alive==0 then
		love.graphics.setColor(255*ExpScale, 255*ExpScale, 255*ExpScale)
		love.graphics.draw(Explosion, Players[1].X-50*ExpScale, Players[1].Y-50*ExpScale, 0, ExpScale, ExpScale, 0, 0, 0, 0)
		love.graphics.draw(Explosion, Players[2].X-50*ExpScale, Players[2].Y-50*ExpScale, 0, ExpScale, ExpScale, 0, 0, 0, 0)
		if ExpScale < 1 then
			ExpScale=ExpScale+0.02
		else
			love.graphics.draw(GO, 512, 220, 0, 1, 1, 0, 0, 0, 0)
			for i=1, string.len(Points), 1 do
				--love.graphics.print(string.sub(Points, i, i), 20*i, 20)
				love.graphics.draw(Numbers[tonumber(string.sub(Points, i, i))], (638-.5*string.len(Points)*20)+22*(i-1), 362, 0, 1, 1, 0, 0, 0, 0)
			end
		end
	end
end

function Distance(x1, y1, x2, y2)
	return math.sqrt((x1-x2)^2+(y1-y2)^2)
end

function Input(dt)
	if love.keyboard.isDown('w') then
		AddVelocity(0, -dt, 1)
	elseif love.keyboard.isDown('s') then
		AddVelocity(0, dt, 1)
	elseif Players[1].VelocityY>0 then
		AddVelocity(0, .5*-dt, 1)
	elseif Players[1].VelocityY<0 then
		AddVelocity(0, .5*dt, 1)
	end
	
	if love.keyboard.isDown('a') then
		AddVelocity(-dt, 0, 1)
	elseif love.keyboard.isDown('d') then
		AddVelocity(dt, 0, 1)
	elseif Players[1].VelocityX>0 then
		AddVelocity(.5*-dt, 0, 1)
	elseif Players[1].VelocityX<0 then
		AddVelocity(.5*dt, 0, 1)
	end
	
	if love.keyboard.isDown('up') then
		AddVelocity(0, -dt, 2)
	elseif love.keyboard.isDown('down') then
		AddVelocity(0, dt, 2)
	elseif Players[2].VelocityY>0 then
		AddVelocity(0, .5*-dt, 2)
	elseif Players[2].VelocityY<0 then
		AddVelocity(0, .5*dt, 2)
	end
	
	if love.keyboard.isDown('left') then
		AddVelocity(-dt, 0, 2)
	elseif love.keyboard.isDown('right') then
		AddVelocity(dt, 0, 2)
	elseif Players[2].VelocityX>0 then
		AddVelocity(.5*-dt, 0, 2)
	elseif Players[2].VelocityX<0 then
		AddVelocity(.5*dt, 0, 2)
	end
end

function MovePlayers()
	Players[1].X=Players[1].X+Players[1].VelocityX
	Players[1].Y=Players[1].Y+Players[1].VelocityY
	Players[2].X=Players[2].X+Players[2].VelocityX
	Players[2].Y=Players[2].Y+Players[2].VelocityY
end

function AddVelocity(vx, vy, num)
	--Players[num].VelocityX=Players[num].VelocityX+vx
	--Players[num].VelocityY=Players[num].VelocityY+vy
	
	if Players[num].VelocityX<Players[num].Speed then
		--Players[num].VelocityX=Players[num].Speed
		Players[num].VelocityX=Players[num].VelocityX+vx
	end
	if Players[num].VelocityY<Players[num].Speed then
		--Players[num].VelocityY=Players[num].Speed
		Players[num].VelocityY=Players[num].VelocityY+vy
	end
end

function Pull()
	if Distance(Players[1].X, Players[1].Y, Players[2].X, Players[2].Y)>rope then
		local vx=0
		local vy=0
		local rx=0
		local ry=0
		
		rx=math.abs(Players[1].VelocityX)+math.abs(Players[2].VelocityX)
		ry=math.abs(Players[1].VelocityY)+math.abs(Players[2].VelocityY)
		
		if Players[1].X>Players[2].X then
			vx=-elastic
		elseif Players[1].X<Players[2].X then
			vx=elastic
		end
		
		if Players[1].Y>Players[2].Y then
			vy=-elastic
		elseif Players[1].Y<Players[2].Y then
			vy=elastic
		end
		
		return vx*rx+Players[1].VelocityX, vy*ry+Players[1].VelocityY, -vx*rx+Players[2].VelocityX, -vy*ry+Players[2].VelocityY
	else
		return Players[1].VelocityX, Players[1].VelocityY, Players[2].VelocityX, Players[2].VelocityY
	end
end

function Die()
	Alive=0
end

function MoveAsteroids(dt)
	for i=1, table.getn(Asteroids), 1 do
		Asteroids[i].X=Asteroids[i].X+Asteroids[i].VelocityX
		Asteroids[i].Y=Asteroids[i].Y+Asteroids[i].VelocityY
	end
end

function DeathCheck()
	for i=1, table.getn(Asteroids), 1 do
		if Distance(Asteroids[i].X, Asteroids[i].Y, Players[1].X, Players[1].Y)<Asteroids[i].Size+Players[1].Size then
			Die()
		end
		if Distance(Asteroids[i].X, Asteroids[i].Y, Players[2].X, Players[2].Y)<Asteroids[i].Size+Players[2].Size then
			Die()
		end
	end
	if Players[1].X>1280 or Players[1].X<0 or Players[1].Y>720 or Players[1].Y<0 or Players[2].X>1280 or Players[2].X<0 or Players[2].Y>720 or Players[2].Y<0 then
		Die()
	end
end

function Delete(q)
	for i=1, table.getn(Asteroids), 1 do
		if Asteroids[i].X<0-2*Asteroids[i].Size or Asteroids[i].X>1280+2*Asteroids[i].Size or Asteroids[i].Y<0-2*Asteroids[i].Size or Asteroids[i].Y>720+2*Asteroids[i].Size then
			Points=Points+Asteroids[i].Size/12.5
			if q==1 then
				QueuePoint(Asteroids[i].Size/12.5, Asteroids[i].X, Asteroids[i].Y)
			end
			table.remove(Asteroids, i)
			Enemies=Enemies-1
			break
		end
	end
end

function CreateAsteroids()
	if Enemies<maxEnemies then
		for i=maxEnemies, Enemies+1, -1 do
			local mid=Distance(Players[1].X, Players[1].Y, Players[2].X, Players[2].Y)
			local radius=mid+Players[1].Size+Players[2].Size+125
			local x1
			local x2
			local y1
			local y2
			if math.random(0, 1)==0 then
				if (Players[1].X+Players[2].X)/2>radius then
					x1=125
					x2=(Players[1].X+Players[2].X)/2-radius
				else
					x1=(Players[1].X+Players[2].X)/2+radius
					x2=1155
				end
			else
				if (Players[1].X+Players[2].X)/2<1280-radius then
					x1=(Players[1].X+Players[2].X)/2+radius
					x2=1155
				else
					x1=125
					x2=(Players[1].X+Players[2].X)/2-radius
				end
			end
			
			if math.random(0, 1)==0 then
				if (Players[1].Y+Players[2].Y)/2>radius then
					y1=125
					y2=(Players[1].Y+Players[2].Y)/2-radius
				else
					y1=(Players[1].Y+Players[2].Y)/2+radius
					y2=595
				end
			else
				if (Players[1].Y+Players[2].Y)/2<720-radius then
					y1=(Players[1].Y+Players[2].Y)/2+radius
					y2=595
				else
					y1=125
					y2=(Players[1].Y+Players[2].Y)/2-radius
				end
			end
			
			Asteroids[i]=NewObject(math.random(x1, x2), math.random(y1, y2), .1*math.random(-20, 20), .1*math.random(-20, 20), math.random(1, 5)*12.5)
		end
		Enemies=Enemies+1
	end
end

function QueuePoint(amt, x, y)
	Pops[table.getn(Pops)+1]={amt, x, y, 20}
end

function DrawPoints()
	if table.getn(Pops)>=1 then
		for i=1, table.getn(Pops), 1 do
			local x=Pops[i][2]
			local y=Pops[i][3]
			
			if Pops[i][2]>1205 then
				Pops[i][2]=1205
			elseif Pops[i][2]<0 then
				Pops[i][2]=0
			end
			if Pops[i][3]>645 then
				Pops[i][3]=645
			elseif Pops[i][3]<0 then
				Pops[i][3]=0
			end
			love.graphics.draw(PointDraws[Pops[i][1]], x, y, 0, 1, 1, 0, 0, 0, 0)
			
			Pops[i][4]=Pops[i][4]-1
		end
		
		for i=table.getn(Pops), 1, -1 do
			if Pops[i][4]<=0 then
				table.remove(Pops, i)
			end
		end
	end
end

function Setup()
	Players={}
	Pops={}
	Asteroids={}
	math.randomseed(os.time())
	Players[1]=NewPlayer(610, 360, 0, 0, 2, 20)
	Players[2]=NewPlayer(670, 360, 0, 0, 2, 20)
	ExpScale=0
	rope=255
	elastic=.75
	Points=0
	maxEnemies=15
	Enemies=15
	Alive=1
	GOTick=20
	for i=1, Enemies, 1 do
		Asteroids[i]=NewObject(math.random(1, 1155), math.random(0, 1)*540+math.random(1, 216), .1*math.random(-20, 20), .1*math.random(-20, 20), math.random(1, 5)*12.5)
	end
end

function GameOver()
	if love.keyboard.isDown(' ') then
		Setup()
	end
end