--[[
    ██████╗ ██████╗ ██╗███████╗███╗   ███╗
    ██╔══██╗██╔══██╗██║██╔════╝████╗ ████║
    ██████╔╝██████╔╝██║███████╗██╔████╔██║
    ██╔═══╝ ██╔══██╗██║╚════██║██║╚██╔╝██║
    ██║     ██║  ██║██║███████║██║ ╚═╝ ██║
    ╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝     ╚═╝

    Prism UI Library v1.1
    Compatível com Delta Executor (Android/Mobile)
    Single-file · OOP · Glassmorphism · Touch-friendly
    Anti-cheat: gethui() + protect_gui + icon fallback
--]]

local Prism = {}
Prism.__index = Prism

-- ╔══════════════════════════════╗
-- ║  SERVICES                    ║
-- ╚══════════════════════════════╝
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local LocalPlayer      = Players.LocalPlayer

-- ╔══════════════════════════════╗
-- ║  TEMAS                       ║
-- ╚══════════════════════════════╝
local Themes = {
    Dark = {
        Background    = Color3.fromRGB(13, 13, 20),
        Surface       = Color3.fromRGB(20, 20, 30),
        SurfaceAlt    = Color3.fromRGB(26, 26, 38),
        Border        = Color3.fromRGB(50, 50, 72),
        Text          = Color3.fromRGB(232, 232, 245),
        TextSecondary = Color3.fromRGB(140, 140, 165),
        TextMuted     = Color3.fromRGB(75, 75, 100),
        BgAlpha       = 0.08,
        SfAlpha       = 0.12,
    },
    Light = {
        Background    = Color3.fromRGB(242, 242, 250),
        Surface       = Color3.fromRGB(255, 255, 255),
        SurfaceAlt    = Color3.fromRGB(230, 230, 242),
        Border        = Color3.fromRGB(195, 195, 218),
        Text          = Color3.fromRGB(18, 18, 28),
        TextSecondary = Color3.fromRGB(78, 78, 105),
        TextMuted     = Color3.fromRGB(145, 145, 170),
        BgAlpha       = 0.04,
        SfAlpha       = 0.06,
    },
}

-- ╔══════════════════════════════╗
-- ║  UTILITÁRIOS                 ║
-- ╚══════════════════════════════╝
local function Tw(inst, props, dur, sty, dir)
    TweenService:Create(inst,
        TweenInfo.new(dur or 0.2, sty or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function VP() return workspace.CurrentCamera.ViewportSize end

local function Cor(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = p; return c end
local function Str(p, col, th, tr) local s = Instance.new("UIStroke"); s.Color = col or Color3.new(1,1,1); s.Thickness = th or 1; s.Transparency = tr or 0.5; s.Parent = p; return s end
local function Pad(p, t, b, l, r) local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0,t or 0); pad.PaddingBottom = UDim.new(0,b or 0); pad.PaddingLeft = UDim.new(0,l or 0); pad.PaddingRight = UDim.new(0,r or 0); pad.Parent = p; return pad end
local function ListY(p, gap) local l = Instance.new("UIListLayout"); l.FillDirection = Enum.FillDirection.Vertical; l.SortOrder = Enum.SortOrder.LayoutOrder; l.Padding = UDim.new(0, gap or 0); l.Parent = p; return l end

local function SafeRead(f)  local ok,d = pcall(readfile,f);  return ok and d or nil end
local function SafeWrite(f,d) pcall(writefile, f, d) end

-- ╔══════════════════════════════╗
-- ║  ANTI-CHEAT                  ║
-- ╚══════════════════════════════╝
-- Tier 1: gethui() mantém a GUI fora do PlayerGui
--         e invisível para anti-cheats que escaneiam PlayerGui.
-- Tier 2: protect_gui() impede scripts externos de deletar a GUI.
-- Tier 3: fallback para PlayerGui quando nenhum dos dois está disponível.

local function SafeGui()
    local ok, hui = pcall(function() return gethui() end)
    return (ok and hui) and hui or LocalPlayer.PlayerGui
end

local function ProtectGui(sg)
    pcall(function() protect_gui(sg) end)
end

-- ╔══════════════════════════════╗
-- ║  SISTEMA DE ÍCONES           ║
-- ╚══════════════════════════════╝
-- Emoji   → Texto puro. Não carrega asset externo. Mais seguro.
-- AssetID → ImageLabel. Anti-cheats avançados monitoram ContentProvider.
-- ASCII   → Fallback 100% invisível para qualquer anti-cheat.

local AsciiMap = {
    ["⚔️"]="[A]",["🛡️"]="[D]",["🔫"]="[G]",["👁️"]="[V]",["⚡"]="[!]",
    ["💎"]="[*]",["🔧"]="[S]",["🏠"]="[H]",["🚀"]="[>]",["❤️"]="[+]",
    ["💀"]="[X]",["🎯"]="[O]",["📦"]="[B]",["⚙️"]="[C]",["🌙"]="[N]",
    ["☀️"]="[L]",["🔍"]="[F]",["ℹ"]="[I]",["✓"]="[v]",["✅"]="[v]",
    ["❌"]="[x]",["🔔"]="[~]",["📍"]="[P]",["🔄"]="[R]",["👤"]="[U]",
    ["👻"]="[?]",["⬆️"]="[^]",["📦"]="[B]",
}

local _emojiOk = nil
local function EmojiOk()
    if _emojiOk ~= nil then return _emojiOk end
    _emojiOk = pcall(function()
        local t = Instance.new("TextLabel"); t.Text = "⚡"; t:Destroy()
    end)
    return _emojiOk
end

local function ResolveIcon(icon, forceAscii)
    if not icon then return nil end
    if forceAscii or not EmojiOk() then
        return AsciiMap[icon] or "[+]"
    end
    return icon
end

-- ╔══════════════════════════════╗
-- ║  WINDOW CLASS                ║
-- ╚══════════════════════════════╝
local Window = {}; Window.__index = Window
local Tab    = {}; Tab.__index    = Tab

function Window.new(cfg, sg)
    local self = setmetatable({}, Window)
    self.Title      = cfg.Title       or "Prism"
    self.SubTitle   = cfg.SubTitle    or ""
    self.Theme      = cfg.Theme       or "Dark"
    self.Accent     = cfg.AccentColor or Color3.fromRGB(118, 55, 210)
    self.ConfigName = cfg.ConfigName
    self.WatermarkTxt = cfg.Watermark
    self.ScreenGui  = sg
    self.Tabs       = {}
    self.ActiveTab  = nil
    self.Config     = {}
    self._conns     = {}
    self._allEls    = {}   -- todos os elementos (busca global)
    self._iconTier  = EmojiOk() and "emoji" or "ascii"

    self:_LoadConfig()
    self:_Build()
    self:_BuildWatermark()
    self:_BuildNotifArea()
    return self
end

function Window:T() return Themes[self.Theme] or Themes.Dark end
function Window:Icon(i) return ResolveIcon(i, self._iconTier == "ascii") end

-- ── BUILD PRINCIPAL ─────────────────────────
function Window:_Build()
    local vp  = VP()
    local T   = self:T()
    local acc = self.Accent
    local W   = math.clamp(vp.X * 0.90, 310, 570)
    local H   = math.clamp(vp.Y * 0.74, 390, 580)

    -- Frame raiz
    local root = Instance.new("Frame")
    root.Name               = "PrismRoot"
    root.Size               = UDim2.fromOffset(0, 0)
    root.Position           = UDim2.fromScale(0.5, 0.5)
    root.AnchorPoint        = Vector2.new(0.5, 0.5)
    root.BackgroundColor3   = T.Background
    root.BackgroundTransparency = T.BgAlpha
    root.BorderSizePixel    = 0
    root.ClipsDescendants   = true
    root.Parent             = self.ScreenGui
    Cor(root, 14); Str(root, T.Border, 1, 0.3)
    self.Root = root

    -- Reflexo glassmorphism
    local glass = Instance.new("Frame")
    glass.Size = UDim2.fromScale(1, 0.38)
    glass.BackgroundTransparency = 0.91
    glass.BackgroundColor3 = Color3.fromRGB(255,255,255)
    glass.BorderSizePixel = 0; glass.ZIndex = 1; glass.Parent = root
    Cor(glass, 14)

    -- ── HEADER ──────────────────────────────
    local hdr = Instance.new("Frame")
    hdr.Size = UDim2.new(1, 0, 0, 56)
    hdr.BackgroundTransparency = 1; hdr.BorderSizePixel = 0
    hdr.ZIndex = 2; hdr.Parent = root

    local hBg = Instance.new("Frame")
    hBg.Size = UDim2.fromScale(1, 1)
    hBg.BackgroundColor3 = acc; hBg.BackgroundTransparency = 0.08
    hBg.BorderSizePixel = 0; hBg.ZIndex = 2; hBg.Parent = hdr
    Cor(hBg, 14)

    local hGrad = Instance.new("UIGradient")
    hGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(
            math.clamp(acc.R*255*1.25,0,255), math.clamp(acc.G*255*1.25,0,255), math.clamp(acc.B*255*1.25,0,255))),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(
            math.clamp(acc.R*255*0.55,0,255), math.clamp(acc.G*255*0.55,0,255), math.clamp(acc.B*255*0.55,0,255))),
    }); hGrad.Rotation = 125; hGrad.Parent = hBg

    -- cobre cantos inferiores do header
    local hCov = Instance.new("Frame")
    hCov.Size = UDim2.new(1, 0, 0, 14); hCov.Position = UDim2.new(0,0,1,-14)
    hCov.BackgroundColor3 = Color3.fromRGB(math.clamp(acc.R*255*0.55,0,255),math.clamp(acc.G*255*0.55,0,255),math.clamp(acc.B*255*0.55,0,255))
    hCov.BackgroundTransparency = 0.08; hCov.BorderSizePixel = 0
    hCov.ZIndex = 2; hCov.Parent = hBg

    local function Lbl(sz,pos,txt,font,tsz,col,xa)
        local l = Instance.new("TextLabel")
        l.Size = sz; l.Position = pos; l.BackgroundTransparency = 1
        l.Text = txt; l.Font = font or Enum.Font.GothamMedium
        l.TextSize = tsz or 13; l.TextColor3 = col or Color3.fromRGB(255,255,255)
        l.TextXAlignment = xa or Enum.TextXAlignment.Left
        l.ZIndex = 4; l.Parent = hdr; return l
    end
    Lbl(UDim2.new(0.62,0,0,22),UDim2.fromOffset(16,9),self.Title,Enum.Font.GothamBold,16)
    Lbl(UDim2.new(0.62,0,0,15),UDim2.fromOffset(16,33),self.SubTitle,Enum.Font.Gotham,11,
        Color3.fromRGB(225,225,240))

    -- Botões header
    local bRow = Instance.new("Frame")
    bRow.Size = UDim2.fromOffset(96, 30); bRow.Position = UDim2.new(1,-104,0.5,-15)
    bRow.BackgroundTransparency = 1; bRow.ZIndex = 4; bRow.Parent = hdr
    local bL = Instance.new("UIListLayout")
    bL.FillDirection = Enum.FillDirection.Horizontal
    bL.HorizontalAlignment = Enum.HorizontalAlignment.Right
    bL.VerticalAlignment = Enum.VerticalAlignment.Center
    bL.Padding = UDim.new(0, 6); bL.Parent = bRow

    local function HBtn(icon)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(28, 28); b.BackgroundColor3 = Color3.fromRGB(255,255,255)
        b.BackgroundTransparency = 0.8; b.Text = icon; b.Font = Enum.Font.GothamBold
        b.TextSize = 13; b.TextColor3 = Color3.fromRGB(255,255,255)
        b.BorderSizePixel = 0; b.ZIndex = 5; b.Parent = bRow; Cor(b, 8)
        b.MouseButton1Down:Connect(function() Tw(b,{BackgroundTransparency=0.55},0.08) end)
        b.MouseButton1Up:Connect(function()   Tw(b,{BackgroundTransparency=0.8},0.15)  end)
        return b
    end
    self._minBtn   = HBtn("—")
    self._themeBtn = HBtn(self.Theme == "Dark" and "☀️" or "🌙")

    -- ── SIDEBAR ─────────────────────────────
    local side = Instance.new("Frame")
    side.Size = UDim2.new(0, 56, 1, -56); side.Position = UDim2.fromOffset(0, 56)
    side.BackgroundColor3 = T.SurfaceAlt; side.BackgroundTransparency = 0.28
    side.BorderSizePixel = 0; side.ZIndex = 2; side.Parent = root
    Str(side, T.Border, 1, 0.55); self.Sidebar = side
    local sL = Instance.new("UIListLayout")
    sL.FillDirection = Enum.FillDirection.Vertical
    sL.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sL.Padding = UDim.new(0,4); sL.Parent = side
    Pad(side, 8, 0, 0, 0)

    -- ── ÁREA DE CONTEÚDO ────────────────────
    local ca = Instance.new("Frame")
    ca.Name = "ContentArea"; ca.Size = UDim2.new(1,-56,1,-56)
    ca.Position = UDim2.fromOffset(56,56); ca.BackgroundTransparency = 1
    ca.BorderSizePixel = 0; ca.ClipsDescendants = true; ca.ZIndex = 2; ca.Parent = root
    self.ContentArea = ca

    -- Search bar
    local sf = Instance.new("Frame")
    sf.Size = UDim2.new(1,-16,0,38); sf.Position = UDim2.fromOffset(8,8)
    sf.BackgroundColor3 = T.Surface; sf.BackgroundTransparency = 0.18
    sf.BorderSizePixel = 0; sf.ZIndex = 3; sf.Parent = ca
    Cor(sf, 10); Str(sf, T.Border, 1, 0.5); self.SearchFrame = sf

    local sIcon = Instance.new("TextLabel")
    sIcon.Size = UDim2.fromOffset(18,18); sIcon.Position = UDim2.fromOffset(10,10)
    sIcon.BackgroundTransparency = 1; sIcon.Text = "🔍"; sIcon.TextScaled = true
    sIcon.ZIndex = 4; sIcon.Parent = sf

    local sBox = Instance.new("TextBox")
    sBox.Size = UDim2.new(1,-36,1,0); sBox.Position = UDim2.fromOffset(32,0)
    sBox.BackgroundTransparency = 1; sBox.Text = ""
    sBox.PlaceholderText = "Buscar elementos..."; sBox.Font = Enum.Font.Gotham
    sBox.TextSize = 12; sBox.TextColor3 = T.Text; sBox.PlaceholderColor3 = T.TextMuted
    sBox.TextXAlignment = Enum.TextXAlignment.Left; sBox.ClearTextOnFocus = false
    sBox.ZIndex = 4; sBox.Parent = sf; self.SearchBox = sBox

    -- FPS label
    local fpsL = Instance.new("TextLabel")
    fpsL.Size = UDim2.fromOffset(72,16); fpsL.Position = UDim2.new(1,-78,0,20)
    fpsL.BackgroundTransparency = 1; fpsL.Text = "FPS: --"
    fpsL.Font = Enum.Font.GothamMedium; fpsL.TextSize = 10
    fpsL.TextColor3 = T.TextMuted; fpsL.TextXAlignment = Enum.TextXAlignment.Right
    fpsL.ZIndex = 4; fpsL.Parent = ca; self.FpsLabel = fpsL

    -- ── EVENTOS ─────────────────────────────
    self:_Draggable(hdr)
    self._minimized = false

    self._minBtn.MouseButton1Click:Connect(function() self:_Minimize() end)
    self._themeBtn.MouseButton1Click:Connect(function()
        local n = self.Theme == "Dark" and "Light" or "Dark"
        self:_ApplyTheme(n); self._themeBtn.Text = n=="Dark" and "☀️" or "🌙"
    end)
    sBox:GetPropertyChangedSignal("Text"):Connect(function() self:_Filter(sBox.Text) end)

    -- FPS
    local last = tick()
    table.insert(self._conns, RunService.RenderStepped:Connect(function()
        local now = tick()
        fpsL.Text = "FPS: " .. math.min(math.floor(1/math.max(now-last,0.001)), 999)
        last = now
    end))

    -- Animação de abertura
    Tw(root, {Size=UDim2.fromOffset(W,H), BackgroundTransparency=T.BgAlpha},
        0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

-- ── ARRASTAR ────────────────────────────────
function Window:_Draggable(handle)
    local root = self.Root
    local drag, mPos, fPos = false, nil, nil
    local dInp
    handle.InputBegan:Connect(function(inp)
        local ut = inp.UserInputType
        if ut == Enum.UserInputType.MouseButton1 or ut == Enum.UserInputType.Touch then
            drag = true; mPos = inp.Position; fPos = root.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(inp)
        local ut = inp.UserInputType
        if ut == Enum.UserInputType.MouseMovement or ut == Enum.UserInputType.Touch then dInp = inp end
    end)
    table.insert(self._conns, UserInputService.InputChanged:Connect(function(inp)
        if inp == dInp and drag then
            local d = inp.Position - mPos
            root.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset+d.X, fPos.Y.Scale, fPos.Y.Offset+d.Y)
        end
    end))
end

-- ── MINIMIZAR ───────────────────────────────
function Window:_Minimize()
    local vp = VP(); local W = math.clamp(vp.X*0.90,310,570)
    self._minimized = not self._minimized
    if self._minimized then
        Tw(self.Root,{Size=UDim2.fromOffset(W,56)},0.25)
        self._minBtn.Text = "□"
    else
        Tw(self.Root,{Size=UDim2.fromOffset(W,math.clamp(vp.Y*0.74,390,580))},
            0.32, Enum.EasingStyle.Back)
        self._minBtn.Text = "—"
    end
end

-- ── TEMA ────────────────────────────────────
function Window:_ApplyTheme(name)
    self.Theme = name; local T = self:T()
    Tw(self.Root, {BackgroundColor3=T.Background, BackgroundTransparency=T.BgAlpha}, 0.22)
    Tw(self.Sidebar, {BackgroundColor3=T.SurfaceAlt}, 0.22)
    Tw(self.SearchFrame, {BackgroundColor3=T.Surface}, 0.22)
    Tw(self.FpsLabel, {TextColor3=T.TextMuted}, 0.22)
    Tw(self.SearchBox, {TextColor3=T.Text, PlaceholderColor3=T.TextMuted}, 0.22)
    for _, tab in ipairs(self.Tabs) do
        if tab._nameLbl then
            Tw(tab._nameLbl,
                {TextColor3 = tab == self.ActiveTab and Color3.fromRGB(255,255,255) or T.TextSecondary},
                0.2)
        end
    end
end

-- ── FILTRO DE BUSCA ─────────────────────────
function Window:_Filter(q)
    q = q:lower():gsub("^%s*(.-)%s*$","%1")
    for _, el in ipairs(self._allEls) do
        if el._frame then
            el._frame.Visible = q=="" or (el._name or ""):lower():find(q,1,true) ~= nil
        end
    end
end

-- ── WATERMARK ───────────────────────────────
function Window:_BuildWatermark()
    if not self.WatermarkTxt then return end
    local T = self:T(); local acc = self.Accent
    local wf = Instance.new("Frame")
    wf.Size = UDim2.fromOffset(220,28); wf.Position = UDim2.new(1,-228,0,8)
    wf.BackgroundColor3 = T.Surface; wf.BackgroundTransparency = 0.12
    wf.BorderSizePixel = 0; wf.Parent = self.ScreenGui
    Cor(wf,8); Str(wf,acc,1,0.35); self._wmFrame = wf
    local wl = Instance.new("TextLabel")
    wl.Size = UDim2.fromScale(1,1); wl.BackgroundTransparency = 1
    wl.Text = self.WatermarkTxt; wl.Font = Enum.Font.GothamMedium
    wl.TextSize = 11; wl.TextColor3 = acc; wl.ZIndex = 2; wl.Parent = wf
end

-- ── NOTIFICAÇÕES ────────────────────────────
function Window:_BuildNotifArea()
    local nc = Instance.new("Frame")
    nc.Size = UDim2.fromOffset(285,0); nc.Position = UDim2.new(1,-293,1,-8)
    nc.AnchorPoint = Vector2.new(0,1); nc.BackgroundTransparency = 1
    nc.BorderSizePixel = 0; nc.AutomaticSize = Enum.AutomaticSize.Y
    nc.Parent = self.ScreenGui; self.NotifArea = nc
    local nl = Instance.new("UIListLayout")
    nl.FillDirection = Enum.FillDirection.Vertical
    nl.VerticalAlignment = Enum.VerticalAlignment.Bottom
    nl.Padding = UDim.new(0,6); nl.Parent = nc
end

function Window:Notify(cfg)
    local T = self:T(); local acc = self.Accent
    local n = Instance.new("Frame")
    n.Size = UDim2.new(1,0,0,72); n.BackgroundColor3 = T.Surface
    n.BackgroundTransparency = 0.04; n.BorderSizePixel = 0
    n.Position = UDim2.new(1,12,0,0); n.Parent = self.NotifArea
    Cor(n,11); Str(n,acc,1,0.3)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromOffset(3,52); bar.Position = UDim2.fromOffset(9,10)
    bar.BackgroundColor3 = acc; bar.BorderSizePixel = 0; bar.Parent = n; Cor(bar,4)
    local function NLbl(sz,pos,txt,bold,tsz,col,wrap)
        local l = Instance.new("TextLabel"); l.Size = sz; l.Position = pos
        l.BackgroundTransparency = 1; l.Text = txt
        l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
        l.TextSize = tsz or 12; l.TextColor3 = col or T.Text
        l.TextXAlignment = Enum.TextXAlignment.Left; l.TextWrapped = wrap or false
        l.ZIndex = 2; l.Parent = n; return l
    end
    NLbl(UDim2.new(1,-26,0,20),UDim2.fromOffset(18,10),cfg.Title or "Prism",true,13)
    NLbl(UDim2.new(1,-26,0,36),UDim2.fromOffset(18,30),cfg.Content or "",false,11,T.TextSecondary,true)
    Tw(n,{Position=UDim2.new(0,0,0,0)},0.3,Enum.EasingStyle.Back)
    task.delay(cfg.Duration or 4, function()
        Tw(n,{Position=UDim2.new(1,12,0,0),BackgroundTransparency=1},0.25)
        task.wait(0.28); n:Destroy()
    end)
end

-- ── CONFIG SAVE/LOAD ────────────────────────
function Window:_SaveConfig()
    if not self.ConfigName then return end
    local data = {}
    for _, el in ipairs(self._allEls) do
        if el._configKey and el._value ~= nil then
            local v = el._value
            if typeof(v) == "Color3" then
                v = {r=math.floor(v.R*255), g=math.floor(v.G*255), b=math.floor(v.B*255)}
            elseif typeof(v) == "EnumItem" then
                v = v.Name
            end
            data[el._configKey] = v
        end
    end
    local ok, enc = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then SafeWrite("prism_"..self.ConfigName..".json", enc) end
end

function Window:_LoadConfig()
    if not self.ConfigName then return end
    local raw = SafeRead("prism_"..self.ConfigName..".json")
    if not raw then return end
    local ok, d = pcall(HttpService.JSONDecode, HttpService, raw)
    if ok and d then self.Config = d end
end

-- ── ADICIONAR TAB ───────────────────────────
function Window:AddTab(cfg)
    local T   = self:T()
    local acc = self.Accent
    local tab = setmetatable({_name=cfg.Name or "Tab", _icon=cfg.Icon, _elements={}, _window=self}, Tab)

    -- Botão da sidebar
    local sBtn = Instance.new("TextButton")
    sBtn.Size = UDim2.new(1,-8,0,48); sBtn.BackgroundTransparency = 1
    sBtn.Text = ""; sBtn.BorderSizePixel = 0; sBtn.ZIndex = 3; sBtn.Parent = self.Sidebar
    Cor(sBtn,9); tab._sideBtn = sBtn
    sBtn.MouseButton1Down:Connect(function() Tw(sBtn,{BackgroundTransparency=0.55},0.08) end)

    local ic = self:Icon(cfg.Icon)
    if ic then
        local il = Instance.new("TextLabel")
        il.Size = UDim2.fromOffset(24,24); il.Position = UDim2.new(0.5,-12,0,4)
        il.BackgroundTransparency = 1; il.Text = ic; il.TextScaled = true
        il.ZIndex = 4; il.Parent = sBtn
        local nl = Instance.new("TextLabel")
        nl.Size = UDim2.new(1,-2,0,14); nl.Position = UDim2.new(0,1,1,-16)
        nl.BackgroundTransparency = 1; nl.Text = cfg.Name or ""
        nl.Font = Enum.Font.Gotham; nl.TextSize = 8
        nl.TextColor3 = T.TextSecondary; nl.ZIndex = 4; nl.Parent = sBtn; tab._nameLbl = nl
    else
        local nl = Instance.new("TextLabel")
        nl.Size = UDim2.fromScale(1,1); nl.BackgroundTransparency = 1
        nl.Text = cfg.Name or ""; nl.Font = Enum.Font.GothamMedium
        nl.TextSize = 10; nl.TextColor3 = T.TextSecondary; nl.TextWrapped = true
        nl.ZIndex = 4; nl.Parent = sBtn; tab._nameLbl = nl
    end

    -- Frame de conteúdo da tab (dentro da área de conteúdo)
    local cf = Instance.new("Frame")
    cf.Size = UDim2.new(1,0,1,-50); cf.Position = UDim2.fromOffset(0,50)
    cf.BackgroundTransparency = 1; cf.Visible = false
    cf.BorderSizePixel = 0; cf.ZIndex = 2; cf.Parent = self.ContentArea
    tab._contentFrame = cf

    -- ScrollingFrame PRÓPRIO de cada tab
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Scroll_"..tab._name
    scroll.Size = UDim2.fromScale(1,1); scroll.Position = UDim2.fromScale(0,0)
    scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3; scroll.ScrollBarImageColor3 = self.Accent
    scroll.CanvasSize = UDim2.fromScale(1,0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ZIndex = 3; scroll.Parent = cf; tab._scroll = scroll

    local sL = Instance.new("UIListLayout")
    sL.FillDirection = Enum.FillDirection.Vertical; sL.SortOrder = Enum.SortOrder.LayoutOrder
    sL.Padding = UDim.new(0,6); sL.Parent = scroll
    Pad(scroll,5,10,5,5)

    sBtn.MouseButton1Click:Connect(function() self:_ActivateTab(tab) end)
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then self:_ActivateTab(tab) end
    return tab
end

function Window:_ActivateTab(target)
    local T = self:T(); local acc = self.Accent
    for _, tab in ipairs(self.Tabs) do
        local active = tab == target
        if active then
            Tw(tab._sideBtn,{BackgroundColor3=acc, BackgroundTransparency=0.18},0.18)
            if tab._nameLbl then Tw(tab._nameLbl,{TextColor3=Color3.fromRGB(255,255,255)},0.15) end
            tab._contentFrame.Visible = true
        else
            Tw(tab._sideBtn,{BackgroundTransparency=1},0.18)
            if tab._nameLbl then Tw(tab._nameLbl,{TextColor3=T.TextSecondary},0.15) end
            tab._contentFrame.Visible = false
        end
    end
    self.ActiveTab = target
end

function Window:AddCreditsTab(cfg)
    local tab = self:AddTab({Name="ℹ",Icon="ℹ"})
    tab:AddParagraph({Title="💎 "..(cfg.ScriptName or self.Title), Content=cfg.Description or ""})
    tab:AddSeparator({Title="Informações"})
    if cfg.Author  then tab:AddLabel({Text="👤 Autor: "  ..cfg.Author}) end
    if cfg.Version then tab:AddLabel({Text="📦 Versão: "..cfg.Version}) end
    if cfg.Discord then tab:AddLabel({Text="💬 Discord: "..cfg.Discord}) end
end

function Window:Destroy()
    for _, c in ipairs(self._conns) do c:Disconnect() end
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

-- ╔══════════════════════════════╗
-- ║  TAB: HELPERS                ║
-- ╚══════════════════════════════╝
local function Reg(tab, frame, name)
    local el = {_frame=frame, _name=name, _value=nil, _configKey=nil}
    table.insert(tab._elements, el)
    table.insert(tab._window._allEls, el)
    return el
end

-- Cria o frame base de elemento (com ícone, nome, descrição)
local function Base(tab, cfg, h)
    local T   = tab._window:T()
    local acc = tab._window.Accent
    h = h or 46

    local fr = Instance.new("Frame")
    fr.Name = cfg.Name or "El"
    fr.Size = UDim2.new(1,0,0,h)
    fr.BackgroundColor3 = T.Surface; fr.BackgroundTransparency = T.SfAlpha
    fr.BorderSizePixel = 0; fr.LayoutOrder = #tab._elements+1
    fr.Parent = tab._scroll  -- ← cada tab tem seu próprio scroll
    Cor(fr,10); Str(fr,T.Border,1,0.58)

    local sx = 12
    local ic = tab._window:Icon(cfg.Icon)
    if ic then
        local il = Instance.new("TextLabel")
        il.Size = UDim2.fromOffset(20,20); il.Position = UDim2.fromOffset(12,h/2-10)
        il.BackgroundTransparency = 1; il.Text = ic; il.TextScaled = true
        il.ZIndex = 3; il.Parent = fr; sx = 36
    end

    local ny = cfg.Description and 10 or (h/2-10)
    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(0.56,-sx,0,cfg.Description and 18 or 20)
    nl.Position = UDim2.fromOffset(sx,ny)
    nl.BackgroundTransparency = 1; nl.Text = cfg.Name or ""
    nl.Font = Enum.Font.GothamMedium; nl.TextSize = 13
    nl.TextColor3 = T.Text; nl.TextXAlignment = Enum.TextXAlignment.Left
    nl.ZIndex = 3; nl.Parent = fr

    if cfg.Description then
        local dl = Instance.new("TextLabel")
        dl.Size = UDim2.new(0.65,-sx,0,13); dl.Position = UDim2.fromOffset(sx,29)
        dl.BackgroundTransparency = 1; dl.Text = cfg.Description
        dl.Font = Enum.Font.Gotham; dl.TextSize = 10; dl.TextColor3 = T.TextMuted
        dl.TextXAlignment = Enum.TextXAlignment.Left; dl.ZIndex = 3; dl.Parent = fr
    end
    return fr, sx
end

-- ╔══════════════════════════════╗
-- ║  TAB: COMPONENTES            ║
-- ╚══════════════════════════════╝

-- ── BUTTON ──────────────────────────────────
function Tab:AddButton(cfg)
    local T=self._window:T(); local acc=self._window.Accent
    local fr,_=Base(self,cfg,48)
    local btn = Instance.new("TextButton")
    btn.Size=UDim2.fromOffset(72,30); btn.Position=UDim2.new(1,-80,0.5,-15)
    btn.BackgroundColor3=acc; btn.BackgroundTransparency=0.08
    btn.Text="Run"; btn.Font=Enum.Font.GothamBold; btn.TextSize=11
    btn.TextColor3=Color3.fromRGB(255,255,255); btn.BorderSizePixel=0
    btn.ZIndex=4; btn.Parent=fr; Cor(btn,8)
    local g=Instance.new("UIGradient"); g.Rotation=90
    g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))})
    g.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.75),NumberSequenceKeypoint.new(1,1)}); g.Parent=btn
    btn.MouseButton1Down:Connect(function() Tw(btn,{BackgroundTransparency=0.35,Size=UDim2.fromOffset(68,28)},0.08) end)
    btn.MouseButton1Up:Connect(function()
        Tw(btn,{BackgroundTransparency=0.08,Size=UDim2.fromOffset(72,30)},0.15)
        if cfg.Callback then task.spawn(cfg.Callback) end
    end)
    return Reg(self,fr,cfg.Name)
end

-- ── TOGGLE ──────────────────────────────────
function Tab:AddToggle(cfg)
    local T=self._window:T(); local acc=self._window.Accent
    local fr,_=Base(self,cfg,48)
    local val = cfg.Default or false
    if self._window.Config[cfg.Name] ~= nil then val = self._window.Config[cfg.Name] end

    local track=Instance.new("Frame")
    track.Size=UDim2.fromOffset(46,25); track.Position=UDim2.new(1,-54,0.5,-12)
    track.BackgroundColor3=val and acc or T.Border; track.BorderSizePixel=0
    track.ZIndex=4; track.Parent=fr; Cor(track,13)

    local knob=Instance.new("Frame")
    knob.Size=UDim2.fromOffset(19,19); knob.Position=UDim2.fromOffset(val and 24 or 3,3)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0
    knob.ZIndex=5; knob.Parent=track; Cor(knob,10); Str(knob,Color3.new(0,0,0),1,0.72)

    local hit=Instance.new("TextButton"); hit.Size=UDim2.fromScale(1,1)
    hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=6; hit.Parent=track

    local el=Reg(self,fr,cfg.Name); el._value=val; el._configKey=cfg.Name

    local function Set(v)
        val=v; el._value=v
        Tw(track,{BackgroundColor3=v and acc or T.Border},0.2)
        Tw(knob,{Position=UDim2.fromOffset(v and 24 or 3,3)},0.2)
        if cfg.Callback then task.spawn(cfg.Callback,v) end
        self._window:_SaveConfig()
    end
    Set(val); el.SetValue=Set
    hit.MouseButton1Click:Connect(function() Set(not val) end)
    return el
end

-- ── SLIDER ──────────────────────────────────
function Tab:AddSlider(cfg)
    local T=self._window:T(); local acc=self._window.Accent
    local fr,_=Base(self,cfg,66)
    local min=cfg.Min or 0; local max=cfg.Max or 100
    local step=cfg.Step or 1
    local val=cfg.Default or min
    if self._window.Config[cfg.Name] ~= nil then val=self._window.Config[cfg.Name] end
    val=math.clamp(val,min,max)

    local vl=Instance.new("TextLabel")
    vl.Size=UDim2.fromOffset(44,16); vl.Position=UDim2.new(1,-50,0,10)
    vl.BackgroundTransparency=1; vl.Text=tostring(val)
    vl.Font=Enum.Font.GothamMedium; vl.TextSize=12; vl.TextColor3=acc
    vl.TextXAlignment=Enum.TextXAlignment.Right; vl.ZIndex=3; vl.Parent=fr

    local tBg=Instance.new("Frame")
    tBg.Size=UDim2.new(1,-22,0,6); tBg.Position=UDim2.fromOffset(11,48)
    tBg.BackgroundColor3=T.Border; tBg.BorderSizePixel=0; tBg.ZIndex=3; tBg.Parent=fr; Cor(tBg,3)

    local fill=Instance.new("Frame")
    fill.Size=UDim2.new((val-min)/(max-min),0,1,0); fill.BackgroundColor3=acc
    fill.BorderSizePixel=0; fill.ZIndex=4; fill.Parent=tBg; Cor(fill,3)
    local fg=Instance.new("UIGradient"); fg.Rotation=90
    fg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(180,180,180))})
    fg.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.5),NumberSequenceKeypoint.new(1,1)}); fg.Parent=fill

    local thumb=Instance.new("Frame")
    thumb.Size=UDim2.fromOffset(17,17); thumb.Position=UDim2.new((val-min)/(max-min),-8,0.5,-8)
    thumb.BackgroundColor3=Color3.fromRGB(255,255,255); thumb.BorderSizePixel=0
    thumb.ZIndex=5; thumb.Parent=tBg; Cor(thumb,9); Str(thumb,acc,2,0.1)

    local dragging=false
    local function Upd(px)
        local rel=math.clamp((px-tBg.AbsolutePosition.X)/tBg.AbsoluteSize.X,0,1)
        local snap=math.floor((min+rel*(max-min))/step+0.5)*step
        snap=math.clamp(snap,min,max); if snap==val then return end; val=snap
        local pct=(val-min)/(max-min)
        Tw(fill,{Size=UDim2.new(pct,0,1,0)},0.05); Tw(thumb,{Position=UDim2.new(pct,-8,0.5,-8)},0.05)
        vl.Text=tostring(val); if cfg.Callback then task.spawn(cfg.Callback,val) end
    end
    thumb.InputBegan:Connect(function(i)
        local ut=i.UserInputType
        if ut==Enum.UserInputType.MouseButton1 or ut==Enum.UserInputType.Touch then dragging=true end
    end)
    tBg.InputBegan:Connect(function(i)
        local ut=i.UserInputType
        if ut==Enum.UserInputType.MouseButton1 or ut==Enum.UserInputType.Touch then Upd(i.Position.X) end
    end)
    table.insert(self._window._conns, UserInputService.InputChanged:Connect(function(i)
        local ut=i.UserInputType
        if dragging and (ut==Enum.UserInputType.MouseMovement or ut==Enum.UserInputType.Touch) then Upd(i.Position.X) end
    end))
    table.insert(self._window._conns, UserInputService.InputEnded:Connect(function(i)
        local ut=i.UserInputType
        if ut==Enum.UserInputType.MouseButton1 or ut==Enum.UserInputType.Touch then
            if dragging then dragging=false; self._window:_SaveConfig() end
        end
    end))

    local el=Reg(self,fr,cfg.Name); el._value=val; el._configKey=cfg.Name
    el.SetValue=function(v)
        v=math.clamp(v,min,max); val=v; el._value=v
        local pct=(v-min)/(max-min)
        Tw(fill,{Size=UDim2.new(pct,0,1,0)},0.1); Tw(thumb,{Position=UDim2.new(pct,-8,0.5,-8)},0.1)
        vl.Text=tostring(v)
    end
    return el
end

-- ── DROPDOWN (helper compartilhado) ─────────
local function BuildDropFrame(tab, cfg)
    local T=tab._window:T(); local acc=tab._window.Accent
    local fr=Instance.new("Frame")
    fr.Name=cfg.Name or "Drop"; fr.Size=UDim2.new(1,0,0,46)
    fr.BackgroundColor3=T.Surface; fr.BackgroundTransparency=T.SfAlpha
    fr.BorderSizePixel=0; fr.ClipsDescendants=false
    fr.LayoutOrder=#tab._elements+1; fr.ZIndex=6
    fr.Parent=tab._scroll; Cor(fr,10); Str(fr,T.Border,1,0.58)

    local sx=12
    local ic=tab._window:Icon(cfg.Icon)
    if ic then
        local il=Instance.new("TextLabel"); il.Size=UDim2.fromOffset(20,20)
        il.Position=UDim2.fromOffset(12,13); il.BackgroundTransparency=1
        il.Text=ic; il.TextScaled=true; il.ZIndex=7; il.Parent=fr; sx=36
    end

    local nl=Instance.new("TextLabel")
    nl.Size=UDim2.new(0.5,-sx,0,20); nl.Position=UDim2.fromOffset(sx,13)
    nl.BackgroundTransparency=1; nl.Text=cfg.Name or ""
    nl.Font=Enum.Font.GothamMedium; nl.TextSize=13; nl.TextColor3=T.Text
    nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=7; nl.Parent=fr

    local valLbl=Instance.new("TextLabel")
    valLbl.Size=UDim2.new(0.4,0,0,20); valLbl.Position=UDim2.new(0.55,0,0,13)
    valLbl.BackgroundTransparency=1; valLbl.Font=Enum.Font.Gotham
    valLbl.TextSize=11; valLbl.TextColor3=acc
    valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=7; valLbl.Parent=fr

    local arrow=Instance.new("TextLabel")
    arrow.Size=UDim2.fromOffset(14,14); arrow.Position=UDim2.new(1,-20,0.5,-7)
    arrow.BackgroundTransparency=1; arrow.Text="▼"; arrow.Font=Enum.Font.GothamBold
    arrow.TextSize=9; arrow.TextColor3=T.TextMuted; arrow.ZIndex=7; arrow.Parent=fr

    local hit=Instance.new("TextButton"); hit.Size=UDim2.fromScale(1,1)
    hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=8; hit.Parent=fr

    local dList=Instance.new("Frame")
    dList.Size=UDim2.new(1,0,0,0); dList.Position=UDim2.new(0,0,1,4)
    dList.BackgroundColor3=T.SurfaceAlt; dList.BackgroundTransparency=0.04
    dList.BorderSizePixel=0; dList.Visible=false; dList.ZIndex=12; dList.Parent=fr
    Cor(dList,10); Str(dList,acc,1,0.3)

    local dL=Instance.new("UIListLayout"); dL.FillDirection=Enum.FillDirection.Vertical
    dL.Padding=UDim.new(0,2); dL.Parent=dList
    Pad(dList,4,4,4,4)

    return fr, valLbl, arrow, hit, dList, T, acc
end

-- ── DROPDOWN ────────────────────────────────
function Tab:AddDropdown(cfg)
    local opts=cfg.Options or {}
    local sel=cfg.Default or opts[1]
    if self._window.Config[cfg.Name] ~= nil then sel=self._window.Config[cfg.Name] end
    local open=false

    local fr,valLbl,arrow,hit,dList,T,acc=BuildDropFrame(self,cfg)
    dList.Size=UDim2.new(1,0,0,#opts*34+8)
    valLbl.Text=tostring(sel or "Selecionar")

    local el=Reg(self,fr,cfg.Name); el._value=sel; el._configKey=cfg.Name

    for _,opt in ipairs(opts) do
        local ob=Instance.new("TextButton"); ob.Size=UDim2.new(1,0,0,30)
        ob.BackgroundColor3=T.Surface; ob.BackgroundTransparency=opt==sel and 0.25 or 0.65
        ob.Text=tostring(opt); ob.Font=Enum.Font.Gotham; ob.TextSize=12
        ob.TextColor3=opt==sel and acc or T.Text; ob.BorderSizePixel=0; ob.ZIndex=13; ob.Parent=dList; Cor(ob,7)
        ob.MouseButton1Click:Connect(function()
            sel=opt; el._value=opt; valLbl.Text=tostring(opt)
            for _,ch in ipairs(dList:GetChildren()) do
                if ch:IsA("TextButton") then
                    local s=ch.Text==tostring(opt)
                    ch.BackgroundTransparency=s and 0.25 or 0.65; ch.TextColor3=s and acc or T.Text
                end
            end
            open=false; dList.Visible=false; Tw(arrow,{Rotation=0},0.15)
            if cfg.Callback then task.spawn(cfg.Callback,opt) end
            self._window:_SaveConfig()
        end)
    end
    hit.MouseButton1Click:Connect(function() open=not open; dList.Visible=open; Tw(arrow,{Rotation=open and 180 or 0},0.15) end)
    return el
end

-- ── MULTI-DROPDOWN ──────────────────────────
function Tab:AddMultiDropdown(cfg)
    local opts=cfg.Options or {}; local open=false; local sel={}
    if cfg.Default then for _,v in ipairs(cfg.Default) do sel[v]=true end end

    local fr,valLbl,arrow,hit,dList,T,acc=BuildDropFrame(self,cfg)
    dList.Size=UDim2.new(1,0,0,#opts*34+8)

    local el=Reg(self,fr,cfg.Name); el._value=sel; el._configKey=cfg.Name

    local function UpdC() local n=0; for _ in pairs(sel) do n=n+1 end; valLbl.Text=n.." selecionado(s)" end
    UpdC()

    for _,opt in ipairs(opts) do
        local ob=Instance.new("TextButton"); ob.Size=UDim2.new(1,0,0,30)
        ob.BackgroundColor3=T.Surface; ob.BackgroundTransparency=sel[opt] and 0.25 or 0.65
        ob.Text=(sel[opt] and "✓ " or "  ")..tostring(opt); ob.Font=Enum.Font.Gotham; ob.TextSize=12
        ob.TextColor3=sel[opt] and acc or T.Text; ob.BorderSizePixel=0; ob.ZIndex=13; ob.Parent=dList; Cor(ob,7)
        ob.MouseButton1Click:Connect(function()
            sel[opt]=not sel[opt]
            ob.BackgroundTransparency=sel[opt] and 0.25 or 0.65
            ob.Text=(sel[opt] and "✓ " or "  ")..tostring(opt); ob.TextColor3=sel[opt] and acc or T.Text
            UpdC(); el._value=sel
            local list={}; for k,v in pairs(sel) do if v then table.insert(list,k) end end
            if cfg.Callback then task.spawn(cfg.Callback,list) end
            self._window:_SaveConfig()
        end)
    end
    hit.MouseButton1Click:Connect(function() open=not open; dList.Visible=open; Tw(arrow,{Rotation=open and 180 or 0},0.15) end)
    return el
end

-- ── TEXT INPUT ──────────────────────────────
function Tab:AddTextInput(cfg)
    local T=self._window:T(); local acc=self._window.Accent
    local fr,_=Base(self,cfg,68)
    local iBg=Instance.new("Frame")
    iBg.Size=UDim2.new(1,-22,0,30); iBg.Position=UDim2.fromOffset(11,30)
    iBg.BackgroundColor3=T.SurfaceAlt; iBg.BackgroundTransparency=0.18
    iBg.BorderSizePixel=0; iBg.ZIndex=4; iBg.Parent=fr; Cor(iBg,8)
    local iStr=Str(iBg,T.Border,1,0.42)
    local tb=Instance.new("TextBox")
    tb.Size=UDim2.new(1,-16,1,0); tb.Position=UDim2.fromOffset(8,0)
    tb.BackgroundTransparency=1; tb.Text=cfg.Default or ""
    tb.PlaceholderText=cfg.Placeholder or "Digite aqui..."; tb.Font=Enum.Font.Gotham
    tb.TextSize=12; tb.TextColor3=T.Text; tb.PlaceholderColor3=T.TextMuted
    tb.TextXAlignment=Enum.TextXAlignment.Left; tb.ClearTextOnFocus=false
    tb.ZIndex=5; tb.Parent=iBg
    tb.Focused:Connect(function() Tw(iStr,{Color=acc,Transparency=0},0.15) end)
    tb.FocusLost:Connect(function(e)
        Tw(iStr,{Color=T.Border,Transparency=0.42},0.15)
        if cfg.Callback then task.spawn(cfg.Callback,tb.Text,e) end
    end)
    local el=Reg(self,fr,cfg.Name); el._value=tb.Text; el._configKey=cfg.Name
    return el
end

-- ── LABEL ───────────────────────────────────
function Tab:AddLabel(cfg)
    local T=self._window:T()
    local fr=Instance.new("Frame"); fr.Size=UDim2.new(1,0,0,28)
    fr.BackgroundTransparency=1; fr.BorderSizePixel=0
    fr.LayoutOrder=#self._elements+1; fr.Parent=self._scroll
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-14,1,0)
    l.Position=UDim2.fromOffset(12,0); l.BackgroundTransparency=1
    l.Text=cfg.Text or ""; l.Font=Enum.Font.Gotham; l.TextSize=12
    l.TextColor3=T.TextSecondary; l.TextXAlignment=Enum.TextXAlignment.Left
    l.TextWrapped=true; l.ZIndex=3; l.Parent=fr
    local el=Reg(self,fr,cfg.Text or "Label"); el._label=l
    el.SetText=function(t) l.Text=t end
    return el
end

-- ── SEPARATOR ───────────────────────────────
function Tab:AddSeparator(cfg)
    local T=self._window:T(); local acc=self._window.Accent
    local fr=Instance.new("Frame"); fr.Size=UDim2.new(1,0,0,22)
    fr.BackgroundTransparency=1; fr.LayoutOrder=#self._elements+1; fr.Parent=self._scroll
    local line=Instance.new("Frame"); line.Size=UDim2.new(1,-20,0,1)
    line.Position=UDim2.fromOffset(10,11); line.BackgroundColor3=T.Border
    line.BackgroundTransparency=0.25; line.BorderSizePixel=0; line.Parent=fr
    local g=Instance.new("UIGradient")
    g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.5,acc),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))})
    g.Parent=line
    if cfg and cfg.Title then
        local tl=Instance.new("TextLabel"); tl.Size=UDim2.fromOffset(0,14)
        tl.AutomaticSize=Enum.AutomaticSize.X; tl.AnchorPoint=Vector2.new(0.5,0.5)
        tl.Position=UDim2.fromScale(0.5,0.5); tl.BackgroundColor3=T.Background
        tl.BackgroundTransparency=T.BgAlpha; tl.Text=" "..cfg.Title.." "
        tl.Font=Enum.Font.GothamMedium; tl.TextSize=10; tl.TextColor3=T.TextMuted
        tl.ZIndex=2; tl.Parent=fr; Pad(tl,0,0,3,3)
    end
    return Reg(self,fr,(cfg and cfg.Title) or "Sep")
end

-- ── PARAGRAPH ───────────────────────────────
function Tab:AddParagraph(cfg)
    local T=self._window:T()
    local fr=Instance.new("Frame"); fr.Name=cfg.Title or "Para"
    fr.Size=UDim2.new(1,0,0,0); fr.AutomaticSize=Enum.AutomaticSize.Y
    fr.BackgroundColor3=T.Surface; fr.BackgroundTransparency=T.SfAlpha
    fr.BorderSizePixel=0; fr.LayoutOrder=#self._elements+1; fr.Parent=self._scroll; Cor(fr,10)
    ListY(fr,4); Pad(fr,10,10,10,10)
    if cfg.Title then
        local tl=Instance.new("TextLabel"); tl.Size=UDim2.new(1,0,0,18)
        tl.BackgroundTransparency=1; tl.Text=cfg.Title; tl.Font=Enum.Font.GothamBold
        tl.TextSize=13; tl.TextColor3=T.Text; tl.TextXAlignment=Enum.TextXAlignment.Left
        tl.ZIndex=3; tl.Parent=fr
    end
    local cl=Instance.new("TextLabel"); cl.Size=UDim2.new(1,0,0,0)
    cl.AutomaticSize=Enum.AutomaticSize.Y; cl.BackgroundTransparency=1
    cl.Text=cfg.Content or ""; cl.Font=Enum.Font.Gotham; cl.TextSize=11
    cl.TextColor3=T.TextSecondary; cl.TextXAlignment=Enum.TextXAlignment.Left
    cl.TextWrapped=true; cl.ZIndex=3; cl.Parent=fr
    return Reg(self,fr,cfg.Title or "Para")
end

-- ── COLOR PICKER ────────────────────────────
function Tab:AddColorPicker(cfg)
    local T=self._window:T(); local acc=self._window.Accent
    local def=cfg.Default or Color3.fromRGB(255,80,80)
    local cur=def; local open=false

    local fr=Instance.new("Frame"); fr.Name=cfg.Name or "Color"
    fr.Size=UDim2.new(1,0,0,46); fr.BackgroundColor3=T.Surface
    fr.BackgroundTransparency=T.SfAlpha; fr.BorderSizePixel=0; fr.ClipsDescendants=false
    fr.LayoutOrder=#self._elements+1; fr.ZIndex=6; fr.Parent=self._scroll; Cor(fr,10); Str(fr,T.Border,1,0.58)

    local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(0.6,-12,0,20); nl.Position=UDim2.fromOffset(12,13)
    nl.BackgroundTransparency=1; nl.Text=cfg.Name or "Cor"; nl.Font=Enum.Font.GothamMedium
    nl.TextSize=13; nl.TextColor3=T.Text; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=7; nl.Parent=fr

    local prev=Instance.new("TextButton"); prev.Size=UDim2.fromOffset(34,24)
    prev.Position=UDim2.new(1,-42,0.5,-12); prev.BackgroundColor3=def; prev.BorderSizePixel=0
    prev.Text=""; prev.ZIndex=7; prev.Parent=fr; Cor(prev,7); Str(prev,T.Border,1,0.3)

    local panel=Instance.new("Frame"); panel.Size=UDim2.new(1,0,0,108)
    panel.Position=UDim2.new(0,0,1,4); panel.BackgroundColor3=T.SurfaceAlt
    panel.BackgroundTransparency=0.04; panel.BorderSizePixel=0; panel.Visible=false
    panel.ZIndex=12; panel.Parent=fr; Cor(panel,10); Str(panel,acc,1,0.3)
    ListY(panel,4); Pad(panel,8,8,8,8)

    local rV,gV,bV=math.floor(def.R*255),math.floor(def.G*255),math.floor(def.B*255)
    local function UpdC()
        cur=Color3.fromRGB(rV,gV,bV); prev.BackgroundColor3=cur
        if cfg.Callback then task.spawn(cfg.Callback,cur) end
    end

    local function MiniSldr(lbl,iv,col,onCh)
        local sf=Instance.new("Frame"); sf.Size=UDim2.new(1,0,0,22); sf.BackgroundTransparency=1; sf.Parent=panel
        local ll=Instance.new("TextLabel"); ll.Size=UDim2.fromOffset(12,14); ll.Position=UDim2.fromOffset(0,4)
        ll.BackgroundTransparency=1; ll.Text=lbl; ll.Font=Enum.Font.GothamBold
        ll.TextSize=10; ll.TextColor3=col; ll.ZIndex=13; ll.Parent=sf
        local vl=Instance.new("TextLabel"); vl.Size=UDim2.fromOffset(26,14); vl.Position=UDim2.new(1,-26,0,4)
        vl.BackgroundTransparency=1; vl.Text=tostring(iv); vl.Font=Enum.Font.GothamMedium
        vl.TextSize=10; vl.TextColor3=T.TextSecondary; vl.TextXAlignment=Enum.TextXAlignment.Right
        vl.ZIndex=13; vl.Parent=sf
        local tk=Instance.new("Frame"); tk.Size=UDim2.new(1,-46,0,5); tk.Position=UDim2.fromOffset(16,9)
        tk.BackgroundColor3=T.Border; tk.BorderSizePixel=0; tk.ZIndex=13; tk.Parent=sf; Cor(tk,3)
        local fl=Instance.new("Frame"); fl.Size=UDim2.new(iv/255,0,1,0); fl.BackgroundColor3=col
        fl.BorderSizePixel=0; fl.ZIndex=14; fl.Parent=tk; Cor(fl,3)
        local drag=false
        tk.InputBegan:Connect(function(i) local ut=i.UserInputType
            if ut==Enum.UserInputType.MouseButton1 or ut==Enum.UserInputType.Touch then drag=true end end)
        table.insert(self._window._conns, UserInputService.InputChanged:Connect(function(i) local ut=i.UserInputType
            if drag and (ut==Enum.UserInputType.MouseMovement or ut==Enum.UserInputType.Touch) then
                local rel=math.clamp((i.Position.X-tk.AbsolutePosition.X)/tk.AbsoluteSize.X,0,1)
                local v=math.floor(rel*255); vl.Text=tostring(v)
                Tw(fl,{Size=UDim2.new(v/255,0,1,0)},0.04); onCh(v); UpdC()
            end end))
        table.insert(self._window._conns, UserInputService.InputEnded:Connect(function(i) local ut=i.UserInputType
            if ut==Enum.UserInputType.MouseButton1 or ut==Enum.UserInputType.Touch then drag=false end end))
    end
    MiniSldr("R",rV,Color3.fromRGB(230,60,60),  function(v) rV=v end)
    MiniSldr("G",gV,Color3.fromRGB(60,200,80),  function(v) gV=v end)
    MiniSldr("B",bV,Color3.fromRGB(60,120,230), function(v) bV=v end)
    prev.MouseButton1Click:Connect(function() open=not open; panel.Visible=open end)

    local el=Reg(self,fr,cfg.Name); el._value=cur; return el
end

-- ── KEYBIND ─────────────────────────────────
function Tab:AddKeybind(cfg)
    local T=self._window:T(); local acc=self._window.Accent
    local fr,_=Base(self,cfg,48)
    local curKey=cfg.Default or Enum.KeyCode.Unknown; local listening=false
    local kBtn=Instance.new("TextButton"); kBtn.Size=UDim2.fromOffset(82,28)
    kBtn.Position=UDim2.new(1,-90,0.5,-14); kBtn.BackgroundColor3=T.SurfaceAlt
    kBtn.BackgroundTransparency=0.18; kBtn.Text=curKey==Enum.KeyCode.Unknown and "Nenhum" or curKey.Name
    kBtn.Font=Enum.Font.GothamMedium; kBtn.TextSize=11; kBtn.TextColor3=acc
    kBtn.BorderSizePixel=0; kBtn.ZIndex=4; kBtn.Parent=fr; Cor(kBtn,8); Str(kBtn,acc,1,0.3)
    kBtn.MouseButton1Click:Connect(function()
        if listening then return end; listening=true
        kBtn.Text="Pressione..."; kBtn.TextColor3=T.TextMuted
        local con; con=UserInputService.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.Keyboard then
                curKey=i.KeyCode; kBtn.Text=curKey.Name; kBtn.TextColor3=acc; listening=false; con:Disconnect()
                if cfg.Callback then task.spawn(cfg.Callback,curKey) end
            end
        end)
    end)
    local el=Reg(self,fr,cfg.Name); el._value=curKey; el._configKey=cfg.Name
    table.insert(self._window._conns, UserInputService.InputBegan:Connect(function(i,processed)
        if not processed and i.KeyCode==curKey and cfg.OnPress then task.spawn(cfg.OnPress) end
    end))
    return el
end

-- ╔══════════════════════════════╗
-- ║  API PÚBLICA                 ║
-- ╚══════════════════════════════╝
function Prism:CreateWindow(cfg)
    -- Limpa instâncias anteriores nos dois possíveis containers
    local pg  = LocalPlayer.PlayerGui:FindFirstChild("PrismUI")
    local ok, hui = pcall(function() return gethui() end)
    if pg  then pg:Destroy()  end
    if ok and hui then
        local old = hui:FindFirstChild("PrismUI")
        if old then old:Destroy() end
    end

    local sg = Instance.new("ScreenGui")
    sg.Name           = "PrismUI"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 999
    sg.IgnoreGuiInset = true

    -- Tier 1: protect_gui antes de parear
    ProtectGui(sg)
    -- Tier 2: gethui() ou PlayerGui
    sg.Parent = SafeGui()

    return Window.new(cfg, sg)
end

-- Helper público de ícone
function Prism.Icon(icon, window)
    if not icon then return nil end
    return ResolveIcon(icon, window and window._iconTier=="ascii")
end

return Prism
