--
-- Author: leeshuan
-- Date: 2016-01-04 17:04:20
--
local AudioManager = class("AudioManager")

audioManager_Instance = nil

function AudioManager:getInstance()
	if audioManager_Instance == nil then 
		audioManager_Instance = AudioManager:new()
	end
	return audioManager_Instance
end

function AudioManager:preLoadAllAudio()
	 for i,v in ipairs(Tables.SoundTable ) do 
	 	audio.preloadSound( v.FilePath ) 
	 	if v.FilePath_female ~=nil and v.FilePath_female ~=""   then 
	 		audio.preloadSound( v.FilePath_female ) 
	 	end 	
	  end 
end

function AudioManager:ctor()
	self._isOpenMusic = cc.UserDefault:getInstance():getBoolForKey("isOpenMusic", true)
	self._isOpenMusicEffect = cc.UserDefault:getInstance():getBoolForKey("isOpenMusicEffect", true)
	--self:preLoadAllAudio()
    audio.setMusicVolume(1)
    self._curMusic = Tables.getSoundPath(55)
	-- todo preload music file
end

function AudioManager:getOpenMusic()
	return self._isOpenMusic
end

function AudioManager:getOpenMusicEffect()
	return self._isOpenMusicEffect
end

function AudioManager:setOpenMusic( isOpenMusic)
	self._isOpenMusic = isOpenMusic
	cc.UserDefault:getInstance():setBoolForKey("isOpenMusic", isOpenMusic)
	if isOpenMusic == true then
		audio.playMusic(self._curMusic, true)
	else
		audio.stopMusic()
	end
end

function AudioManager:setOpenMusicEffect( isOpenMusicEffect )
	self._isOpenMusicEffect = isOpenMusicEffect
	cc.UserDefault:getInstance():setBoolForKey("isOpenMusicEffect", isOpenMusicEffect)
	cc.UserDefault:getInstance():flush()
end

function AudioManager:playMusic( musicName, isLoop )
	if self._isOpenMusic == true then
		audio.playMusic( musicName, isLoop)
	end
end

function AudioManager:playEffect( effectName, isLoop)
	if self._isOpenMusicEffect == true then
		audio.playSound(effectName, isLoop)
	end
end
return AudioManager