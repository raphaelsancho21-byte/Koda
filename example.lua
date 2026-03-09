-- Carregando a Library (local ou remota)
-- v3.0.1

local KodaSource
if readfile then
    -- Executor com acesso a arquivos locais (ex: Synapse, KRNL)
    local ok, result = pcall(readfile, "Koda.lua")
    if ok and result and #result > 100 then
        KodaSource = result
    end
end

if not KodaSource then
    -- Fallback: carrega do GitHub
    local url = "https://raw.githubusercontent.com/raphaelsancho21-byte/Koda/refs/heads/main/Koda.lua?t=" .. os.time()
    local ok, res = pcall(game.HttpGet, game, url)
    if ok and res and #res > 100 then
        KodaSource = res
    else
        error("[Koda] Falha no HttpGet. Verifique se o repositorio existe e se o executor tem acesso HTTP.")
    end
end

local fn, err = loadstring(KodaSource)
if not fn then
    error("[Koda] Erro de sintaxe: " .. tostring(err))
end
local Koda = fn()

-- Criando a Janela Principal
local Window = Koda:CreateWindow({
    Name = "Koda Showcase",
    Theme = "Dark",
    LoadingTitle = "Koda Interface",
    LoadingSubtitle = "by Eye Team",
    Keybind = Enum.KeyCode.K,
    KeySystem = false,
    KeySettings = {
        Title = "Sistema de Verificação",
        Subtitle = "Pegue a key no nosso Discord",
        Link = "https://discord.gg/seulink",
        Key = "Koda-2026"
    },
    StartupNotification = true,
})

-- ==========================================
-- TAB: COMPONENTES BÁSICOS
-- ==========================================
-- Agora você pode usar IDs de imagem (RBXAssetID) ou ícones de texto nas abas!
local BasicTab = Window:CreateTab("Componentes", 4483362458) -- Exemplo com ID de imagem

local Section2 = BasicTab:CreateSection("Alavancas (Toggles)")

BasicTab:CreateToggle({
    Name = "Auto-Farm Exemplo",
    CurrentValue = false,
    Callback = function(Value)
        print("Toggle alterado para:", Value)
    end
})

BasicTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(Value)
        print("Anti-AFK:", Value)
    end
})

-- ==========================================
-- TAB: INPUTS E SLIDERS
-- ==========================================
local InputTab = Window:CreateTab("Avançado", "⚙️") -- Exemplo com ícone de texto

InputTab:CreateSection("Sliders Numéricos")

InputTab:CreateSlider({
    Name = "Velocidade (WalkSpeed)",
    Min = 16,
    Max = 200,
    CurrentValue = 16,
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

InputTab:CreateSlider({
    Name = "Pulo (JumpPower)",
    Min = 50,
    Max = 500,
    CurrentValue = 50,
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end
})

InputTab:CreateSection("Caixas de Texto")

InputTab:CreateInput({
    Name = "Nickname do Script",
    Placeholder = "Digite algo...",
    Callback = function(Text, EnterPressed)
        if EnterPressed then
            print("Texto inserido:", Text)
            Koda:Notify({
                Title = "Input Confirmado",
                Content = "Você digitou: " .. Text,
                Duration = 3
            })
        end
    end
})

-- ==========================================
-- TAB: SELEÇÃO (DROPDOWNS)
-- ==========================================
local ConfigTab = Window:CreateTab("Configuração", 6031289225) -- Exemplo com outro ID de imagem

ConfigTab:CreateSection("Customização Elite")

ConfigTab:CreateDropdown({
    Name = "Trocar Tema",
    Options = {"Dark", "Light"},
    CurrentOption = "Dark",
    Callback = function(Value)
        print("Novo tema selecionado no exemplo:", Value)
    end
})

ConfigTab:CreateSection("Listas de Seleção")

ConfigTab:CreateDropdown({
    Name = "Escolher Mapa",
    Options = {"Floresta", "Deserto", "Vila", "Cidade Futurista", "Espaço"},
    CurrentOption = "Floresta",
    Callback = function(Option)
        print("Mapa selecionado:", Option)
    end
})

ConfigTab:CreateDropdown({
    Name = "Modo de Jogo",
    Options = {"Sobrevivência", "Criativo", "Hardcore"},
    CurrentOption = "Sobrevivência",
    Callback = function(Option)
        print("Modo alterado para:", Option)
    end
})

ConfigTab:CreateSection("Sistemático (NOVO)")

ConfigTab:CreateButton({
    Name = "Testar Alerta de Update",
    Callback = function()
        Koda:ShowUpdateAlert({
            Version = "3.2.1"
        })
    end
})

ConfigTab:CreateSection("Outros")

ConfigTab:CreateButton({
    Name = "Destruir Interface",
    Callback = function()
        -- Exemplo de como você poderia fechar a interface
        print("Botão de fechar pressionado.")
    end
})
