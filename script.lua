for NpcName,NpcData in pairs(NPCsModule:GetAllNPCs()) do
	local cultivation,smallrealm,soulrank,soulenergy,style,ability,location,spawntime,respawntime,dantian,qivalue,coreCFrame,enemyRange,AttackRange,HpBuff,BodyRank
	BodyRank = NpcData.BodyRank
	AttackRange = NpcData.AttackRange
	enemyRange = NpcData.EnimityRange
	cultivation = NpcData.Cultivation
	coreCFrame = NpcData.CoreCFrame
	smallrealm = NpcData.SmallRealm
	spawntime = NpcData.SpawnTime
	location = NpcData.Location
	style = NpcData.Style
	ability = NpcData.Ability
	respawntime = NpcData.RespawnTime
	dantian = NpcData.Dantian
	soulrank = NpcData.SoulRank
	soulenergy = NpcData.SoulEnergy
	qivalue = NpcData.QiValue
	local IsNpcInWorksapce = true
	HpBuff = CoresModule:HealthBuff(cultivation,smallrealm,BodyRank)
	local Character = location:WaitForChild(NpcName, math.huge)




	if style then
		local Humanoid = Character:FindFirstChildOfClass('Humanoid')
		Humanoid.MaxHealth = HpBuff
		Humanoid.Health = HpBuff
		-- NPC Does fight
		local previousHealth = Humanoid.Health
		function AddBuild(Loc)
			for _,v in pairs(rep:WaitForChild('Objects',math.huge):WaitForChild('NPCs',math.huge):WaitForChild('FightingPack',math.huge):GetChildren()) do
				local clone = v:Clone()
				clone.Parent = Loc
				if clone.Name == 'Qi' then
					clone.Value = qivalue
				elseif clone.Name == 'SoulEnergy' then
					clone.Value = soulenergy
				end
			end
		end

		function Respawn(NPCUser)
			if NPCUser == 'Han Dong' or NPCUser == 'Han Hong' then
				print('NOOOOOOOOOOOOOOOOOOOOOOOOOOOOO')
			end
			local clone = rep.NPCsSpawn:FindFirstChild(NPCUser):Clone()
			print(NPCsModule:GetNpcLocation(NPCUser))
			print(NPCUser)
			clone.Parent = NPCsModule:GetNpcLocation(NPCUser)
			clone:FindFirstChildOfClass('Humanoid').MaxHealth = HpBuff
			clone:FindFirstChildOfClass('Humanoid').Health = HpBuff
			IsNpcInWorksapce = true
			AddBuild(clone)
			--Humanoid = clone:FindFirstChildOfClass('Humanoid')
			HumanoidManagement(clone)
		end

		function HumanoidManagement(Loc)
			local Humanoid = Loc:WaitForChild('Humanoid',math.huge)
			if Humanoid then warn(Humanoid.Parent) end
			Humanoid.Died:Connect(function()
				print(Humanoid.Parent.Name)
				local lastAttacker = Loc:FindFirstChild('LastAttacker')
				local player = game.Players:GetPlayerFromCharacter(lastAttacker.Value)
				rep.Remotes.NpcDefeated:Fire(NpcName,location:FindFirstChild(NpcName))

				IsNpcInWorksapce = false
				location:FindFirstChild(NpcName):Destroy()
				wait()

				local spawnedImportant = false
				if NpcName == 'Tiankong' then
					for i=1, respawntime do
						local ShenYuanBarrier = workspace.Map:FindFirstChild('DemonCave'):FindFirstChild('ShenYuanBarrier')
						ShenYuanBarrier.Transparency = 1
						ShenYuanBarrier.CanCollide = false
						print(ShouldWaitForCooldownTiankong.Value)
						if ShouldWaitForCooldownTiankong.Value == true then
							wait(1)
							print(respawntime-i)
						else
							spawnedImportant = true
							Respawn(NpcName)
							break
						end
					end
				elseif NpcName == 'Shenyuan' then
					for i=1, respawntime do
						if ShouldWaitForCooldownShenyuan.Value == true then
							wait(1)
						else
							spawnedImportant = true
							Respawn(NpcName)
							break
						end
					end
				else

				end
				if not spawnedImportant then
					Respawn(NpcName)
				end
				if ShouldWaitForCooldownShenyuan == false and NpcName == 'Shenyuan' then
					ShouldWaitForCooldownShenyuan = true
				end
				if ShouldWaitForCooldownTiankong == false and NpcName == 'Tiankong' then
					ShouldWaitForCooldownTiankong = true
				end
				previousHealth = HpBuff
			end)

			Humanoid.HealthChanged:Connect(function(health)
				if health == 0 then return end
				if health < previousHealth then
					previousHealth = health
					local lastAttacker = Loc:FindFirstChild('LastAttacker')
					if lastAttacker.Value then else 
						if (Humanoid.Parent.PrimaryPart.Position-coreCFrame.Position).Magnitude >= enemyRange*2 then
							Loc.PrimaryPart.CFrame = coreCFrame
						end
						Humanoid:MoveTo(coreCFrame.Position)
						local TimeOut = 0
						repeat wait(.1) TimeOut+=1 until TimeOut == 50 or lastAttacker.Value ~= nil

					end

					while IsNpcInWorksapce and (Humanoid.Health > 0) and Loc and Loc.PrimaryPart ~= nil and (lastAttacker.Value.PrimaryPart.Position-coreCFrame.Position).Magnitude <= enemyRange and wait() do
						if IsNpcInWorksapce == false then
							break
						end
						local waypoints = NPCsModule:GetWayPoints(Loc.PrimaryPart,lastAttacker.Value.PrimaryPart)
						for _,waypoint in pairs(waypoints) do
							Humanoid:MoveTo(waypoint.Position)
						end
						local damage = CoresModule:GetPlayerDamage(NpcName)

						if (Loc.PrimaryPart.Position - lastAttacker.Value.PrimaryPart.Position).Magnitude <= AttackRange then
							rep.Remotes.CombatNPC:Fire(Loc,style, damage)
						end
						if Loc:FindFirstChild('AbilityUsable').Value == true and ability ~= 'none' then
							if lastAttacker.Value then
								rep.Remotes.AbilityUSENPC:Fire(Loc,lastAttacker.Value,ability,damage,Loc:FindFirstChild('AbilityUsable'))
							end
						end
						if lastAttacker.Value:FindFirstChildOfClass('Humanoid').Health == 0  then
							break
						end
					end
					if Humanoid.Health >= 1 then
						Humanoid:MoveTo(coreCFrame.Position)
					end
				end
			end)
		end


		AddBuild(location:WaitForChild(NpcName, math.huge))
		HumanoidManagement(location:WaitForChild(NpcName, math.huge))
	else
		-- NPC Is Just Common
	end

end
