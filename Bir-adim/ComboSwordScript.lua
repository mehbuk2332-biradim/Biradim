--[[
    ROBLOX KOMBOLU KILIÇ SİSTEMİ
    
    Kullanım:
    1. Bu scripti bir Tool içindeki LocalScript olarak kullanın
    2. Tool içinde "Handle" adında bir Part olmalı
    3. Animasyon ID'lerini kendi animasyonlarınızla değiştirin
    4. Script otomatik olarak çalışacaktır
    
    Özellikler:
    - 3 aşamalı kombo sistemi
    - Otomatik kombo sıfırlama
    - Raycast tabanlı hasar sistemi
    - Cooldown mekanizması
    - Ses efekti desteği
    
    Geliştirme: Gelişim Etüt Merkezi - Roblox Dersleri
    Tarih: 2025
]]

-- Değişkenler
local tool = script.Parent
local handle = tool:WaitForChild("Handle")

-- Oyuncu ve karakter referansları
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

-- Ayarlar
local CONFIG = {
    -- Animasyon ID'leri (bunları kendi animasyonlarınızla değiştirin)
    ANIMATIONS = {
        "rbxassetid://89289879",   -- Vuruş 1
        "rbxassetid://186934658",  -- Vuruş 2
        "rbxassetid://186934910"   -- Vuruş 3 (Finisher)
    },
    
    -- Ses ID'leri
    SWING_SOUND = "rbxassetid://12222030",
    HIT_SOUND = "rbxassetid://12222030",
    
    -- Kombo ayarları
    COMBO_RESET_TIME = 1.5,  -- Saniye cinsinden kombo sıfırlama süresi
    ANIMATION_COOLDOWN = 0.5, -- Animasyonlar arası minimum bekleme
    
    -- Hasar ayarları
    DAMAGE = {
        [1] = 10,  -- İlk vuruş hasarı
        [2] = 15,  -- İkinci vuruş hasarı
        [3] = 25   -- Üçüncü vuruş (finisher) hasarı
    },
    DAMAGE_RANGE = 7,  -- Hasar menzili (studs)
    
    -- Görsel efektler
    ENABLE_PARTICLES = true,
    ENABLE_CAMERA_SHAKE = false
}

-- Kombo durumu
local comboState = {
    current = 0,
    lastHitTime = 0,
    isAnimating = false,
    resetCoroutine = nil
}

-- Yüklenmiş animasyonlar
local loadedAnimations = {}

-- Animasyonları yükle
local function loadAnimations()
    for i, animId in ipairs(CONFIG.ANIMATIONS) do
        local animation = Instance.new("Animation")
        animation.AnimationId = animId
        local animTrack = animator:LoadAnimation(animation)
        loadedAnimations[i] = animTrack
        print("Animasyon " .. i .. " yüklendi: " .. animId)
    end
end

-- Ses efekti oluştur
local function createSound(name, soundId)
    local sound = handle:FindFirstChild(name)
    if not sound then
        sound = Instance.new("Sound")
        sound.Name = name
        sound.SoundId = soundId
        sound.Volume = 0.5
        sound.Parent = handle
    end
    return sound
end

-- Kombo sıfırlama
local function resetCombo()
    wait(CONFIG.COMBO_RESET_TIME)
    if tick() - comboState.lastHitTime >= CONFIG.COMBO_RESET_TIME then
        comboState.current = 0
        print("❌ Kombo sıfırlandı!")
    end
end

-- Hasar verme fonksiyonu
local function dealDamage(comboStep)
    local damage = CONFIG.DAMAGE[comboStep] or 10
    local range = CONFIG.DAMAGE_RANGE
    
    -- Handle'ın konumu ve yönü
    local origin = handle.Position
    local direction = handle.CFrame.LookVector * range
    
    -- Raycast parametreleri
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    -- Raycast yap
    local rayResult = workspace:Raycast(origin, direction, raycastParams)
    
    if rayResult then
        local hitPart = rayResult.Instance
        local hitCharacter = hitPart.Parent
        local hitHumanoid = hitCharacter:FindFirstChildOfClass("Humanoid")
        
        if hitHumanoid and hitCharacter ~= character then
            -- Hasar ver
            hitHumanoid:TakeDamage(damage)
            
            -- Görsel efekt
            local hitSound = createSound("HitSound", CONFIG.HIT_SOUND)
            hitSound:Play()
            
            -- Hit marker oluştur
            local hitMarker = Instance.new("Part")
            hitMarker.Size = Vector3.new(1, 1, 0.1)
            hitMarker.Color = Color3.fromRGB(255, 0, 0)
            hitMarker.Material = Enum.Material.Neon
            hitMarker.Anchored = true
            hitMarker.CanCollide = false
            hitMarker.Position = rayResult.Position
            hitMarker.Parent = workspace
            
            -- Hit marker'ı yok et
            game:GetService("Debris"):AddItem(hitMarker, 0.5)
            
            print("💥 Hasar verildi: " .. damage .. " (Kombo: " .. comboStep .. ")")
            return true
        end
    end
    
    return false
end

-- Parçacık efekti oluştur
local function createSwingEffect()
    if not CONFIG.ENABLE_PARTICLES then return end
    
    local particle = handle:FindFirstChild("SwingParticle")
    if not particle then
        particle = Instance.new("ParticleEmitter")
        particle.Name = "SwingParticle"
        particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        particle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        particle.Size = NumberSequence.new(0.5)
        particle.Lifetime = NumberRange.new(0.3)
        particle.Rate = 50
        particle.Speed = NumberRange.new(5)
        particle.Enabled = false
        particle.Parent = handle
    end
    
    particle.Enabled = true
    wait(0.2)
    particle.Enabled = false
end

-- Kılıç sallama ana fonksiyonu
local function swingSword()
    -- Animasyon kontrolü
    if comboState.isAnimating then
        print("⏳ Animasyon devam ediyor...")
        return
    end
    
    -- Kombo ilerlet
    comboState.current = comboState.current + 1
    if comboState.current > #CONFIG.ANIMATIONS then
        comboState.current = 1
    end
    
    comboState.isAnimating = true
    comboState.lastHitTime = tick()
    
    local currentCombo = comboState.current
    print("⚔️ Kombo " .. currentCombo .. " başlatıldı!")
    
    -- Animasyon oynat
    local animTrack = loadedAnimations[currentCombo]
    if animTrack then
        animTrack:Play()
        
        -- Ses efekti
        local swingSound = createSound("SwingSound", CONFIG.SWING_SOUND)
        swingSound:Play()
        
        -- Görsel efekt
        spawn(createSwingEffect)
        
        -- Hasar verme (animasyonun yarısında)
        wait(animTrack.Length * 0.3)
        dealDamage(currentCombo)
        
        -- Animasyon bitişini bekle
        wait(animTrack.Length * 0.4)
    else
        wait(CONFIG.ANIMATION_COOLDOWN)
    end
    
    comboState.isAnimating = false
    
    -- Kombo sıfırlama zamanlayıcısı
    if comboState.resetCoroutine then
        task.cancel(comboState.resetCoroutine)
    end
    comboState.resetCoroutine = task.spawn(resetCombo)
end

-- Olaylar
tool.Activated:Connect(function()
    swingSword()
end)

tool.Equipped:Connect(function()
    print("🗡️ Kılıç kuşanıldı! Kombo sistemine hazır.")
    comboState.current = 0
    comboState.isAnimating = false
end)

tool.Unequipped:Connect(function()
    print("📦 Kılıç çıkarıldı.")
    
    -- Kombo sıfırla
    comboState.current = 0
    comboState.isAnimating = false
    
    -- Tüm animasyonları durdur
    for _, animTrack in ipairs(loadedAnimations) do
        if animTrack.IsPlaying then
            animTrack:Stop()
        end
    end
    
    -- Zamanlayıcıyı iptal et
    if comboState.resetCoroutine then
        task.cancel(comboState.resetCoroutine)
    end
end)

-- Başlangıç
loadAnimations()
print("✅ Kombo Kılıç Sistemi yüklendi!")
print("📖 Kullanım: Kılıcı kuşanın ve sol tıklayarak saldırın!")
