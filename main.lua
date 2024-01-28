local rl = require("raylib")
-- local physac = require("physac")
local recipes = require("recipes")
local assets = require("assets")

local dragging

local screenWidth = 1920 * 1.5
local screenHeight = 1080* 1.5
local cooldown = 0
local burning = false

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window")
rl.InitAudioDevice()
rl.SetTargetFPS(60)

local music = rl.LoadMusicStream("gameAssets/sounds/music.mp3")

rl.PlayMusicStream(music)
rl.SetMasterVolume(0.05)

-- physac.InitPhysics()

-- local floor = physac.CreatePhysicsBodyRectangle({screenWidth / 2, screenHeight}, 500, 100, 10)

local loadedImages = {}
local loadedSounds = {}


local function distance (x1, y1, x2, y2 )
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt ( dx * dx + dy * dy )
end

for i, v in pairs(assets.images) do
    loadedImages[i] = rl.LoadTexture("gameAssets/images/" .. v .. ".png")
end

loadedImages.button.width = loadedImages.button.width * 15
loadedImages.button.height = loadedImages.button.height * 15

loadedImages.smallButton.width = loadedImages.button.width / 2
loadedImages.smallButton.height = loadedImages.button.height / 2

loadedImages.bread.width = loadedImages.bread.width * 3
loadedImages.bread.height = loadedImages.bread.height * 3

loadedImages.mustardBread.width = loadedImages.mustardBread.width * 3
loadedImages.mustardBread.height = loadedImages.mustardBread.height * 3

loadedImages.grilledCheese.width = loadedImages.grilledCheese.width * 2.5
loadedImages.grilledCheese.height = loadedImages.grilledCheese.height * 2.5

loadedImages.slicedBread.width = loadedImages.slicedBread.width * 3
loadedImages.slicedBread.height = loadedImages.slicedBread.height * 3

loadedImages.whisk.width = loadedImages.whisk.width * 4
loadedImages.whisk.height = loadedImages.whisk.height * 4

loadedImages.kitchen.width = loadedImages.kitchen.width * 30
loadedImages.kitchen.height = loadedImages.kitchen.height * 26

loadedImages.kitchenHot.width = loadedImages.kitchenHot.width * 30
loadedImages.kitchenHot.height = loadedImages.kitchenHot.height * 26

loadedImages.egg.width = loadedImages.egg.width * 2.5
loadedImages.egg.height = loadedImages.egg.height * 2.5

loadedImages.cheese.width = loadedImages.cheese.width * 2.5
loadedImages.cheese.height = loadedImages.cheese.height * 2.5

loadedImages.slicedCheese.width = loadedImages.slicedCheese.width * 2
loadedImages.slicedCheese.height = loadedImages.slicedCheese.height * 2

loadedImages.mustard.width = loadedImages.mustard.width * 3
loadedImages.mustard.height = loadedImages.mustard.height * 3

loadedImages.fryingPan.width = loadedImages.fryingPan.width * 5
loadedImages.fryingPan.height = loadedImages.fryingPan.height * 5

loadedImages.knife.width = loadedImages.knife.width * 6
loadedImages.knife.height = loadedImages.knife.height * 6

loadedImages.menuBackground.width = screenWidth * 0.4
loadedImages.menuBackground.height = screenHeight * 0.36

local combinations = {
    {
        loadedImages.mustardBread,
        loadedImages.slicedBread,
        loadedImages.slicedCheese,
        result = {
            texture = loadedImages.grilledCheese,
            floorPoint = 1105,
            dragRadius = 100
        }
    }
}

local objects = {
    -- jarvis = {
    --     type = "image",
    --     position = {
    --         x = 500,
    --         y = 500
    --     },
    --     rotation = 0,
    --     texture = loadedImages.image
    -- },
    -- jarvisText = {
    --     type = "text",
    --     position = {
    --         x = 250,
    --         y = 100
    --     },
    --     textSize = 50,
    --     text = "jarvis jumpscare",
    --     color = rl.BLACK
    -- },
    -- jarvisRectangle = {
    --     type = "rectangle",
    --     position = {
    --         x = 250,
    --         y = 100
    --     },
    --     scale = {
    --         x = 100,
    --         y = 50
    --     },
    --     rotation = 0,
    --     color = rl.RED
    -- }
    {
        type = "image",
        position = {
            x = loadedImages.kitchen.width,
            y = loadedImages.kitchen.height
        },
        rotation = 0,
        texture = loadedImages.kitchen
    },
    knife = {
        type = "image",
        position = {
            x = screenWidth / 1.25 - loadedImages.knife.width / 2,
            y = 50
        },
        speed = {
            x = 0,
            y = 0
        },
        returnPos = {
            x = screenWidth / 5 - loadedImages.knife.width / 2,
            y = 650
        },
        returnRotation = 90,
        rotation = 0,
        texture = loadedImages.knife,
        unAnchored = true,
        locked = true,
        floorPoint = 1115,
        dragRadius = 100,
        utensil = true
    },
    ingredientsButton = {
        type = "image",
        position = {
            x = 500,
            y = loadedImages.button.height / 2 + loadedImages.button.height / 8
        },
        rotation = 0,
        texture = loadedImages.button,
        clicked = function()
            
        end,
        clickedAdded = {
            type = "image",
            position = {
                x = 0 + screenWidth / 2,
                y = 750 + loadedImages.menuBackground.height / 2
            },
            rotation = 0,
            ingredients = true,
            texture = loadedImages.menuBackground
        },
        clickRadius = 200
    },
    fryingPan = {
        type = "image",
        position = {
            x = screenWidth / 1.5 - loadedImages.fryingPan.width / 2,
            y = 0
        },
        speed = {
            x = 0,
            y = 0
        },
        rotation = 0,
        texture = loadedImages.fryingPan,
        unAnchored = true,
        floorPoint = 1115,
        dragRadius = 100,
        utensil = true,
        fryingPan = true,
        inventory = {},
        cookedTime = 0,
        rightClickedFunction = function()

        end,
        rightClickedAdded = {}
    }
    -- ingredientsImage = {
    --     type = "image",
    --     position = {
    --         x = 500,
    --         y = loadedImages.button.height / 2 + loadedImages.button.height / 8
    --     },
    --     rotation = 0,
    --     texture = loadedImages.cheese
    -- }
}

local templates = {
    whisk = {
        type = "image",
        position = {
            x = screenWidth / 2 - loadedImages.whisk.width / 2,
            y = 0
        },
        speed = {
            x = 0,
            y = 0
        },
        rotation = 180,
        texture = loadedImages.whisk,
        unAnchored = true,
        floorPoint = 1050,
        dragRadius = 50
    },
    egg = {
        type = "image",
        position = {
            x = screenWidth / 2.5 - loadedImages.egg.width / 2,
            y = 0
        },
        speed = {
            x = 0,
            y = 0
        },
        rotation = 0,
        texture = loadedImages.egg,
        unAnchored = true,
        floorPoint = 1110,
        dragRadius = 100,
        rightClickedFunction = function(self)
            objects[#objects + 1] = {
                type = "rectangle",
                position = {
                    x = self.position.x,
                    y = self.position.y
                },
                scale = {
                    x = 50,
                    y = 20
                },
                speed = {
                    x = 0,
                    y = 0
                },
                rotation = 0,
                texture = loadedImages.slicedCheese,
                unAnchored = true,
                floorPoint = 1115,
                dragRadius = 100,
                color = rl.YELLOW
            }
        end,
        removeOnRightClick = true
    },
    bread = {
        type = "image",
        position = {
            x = screenWidth / 9 - loadedImages.bread.width / 2,
            y = 0
        },
        speed = {
            x = 0,
            y = 0
        },
        rotation = 0,
        texture = loadedImages.bread,
        unAnchored = true,
        floorPoint = 1095,
        dragRadius = 100,
        sliceable = true,
        sliced = {
            type = "image",
            position = {
                x = screenWidth / 8 - loadedImages.slicedBread.width / 2,
                y = 0
            },
            speed = {
                x = 0,
                y = 0
            },
            rotation = 0,
            texture = loadedImages.slicedBread,
            unAnchored = true,
            floorPoint = 1125,
            dragRadius = 100
        }
    },
    cheese = {
        type = "image",
        position = {
            x = screenWidth / 2 - loadedImages.cheese.width / 2,
            y = 0
        },
        speed = {
            x = 0,
            y = 0
        },
        rotation = 0,
        texture = loadedImages.cheese,
        unAnchored = true,
        floorPoint = 1100,
        dragRadius = 100,
        sliceable = true,
        sliced = {
            type = "image",
            position = {
                x = screenWidth / 8 - loadedImages.slicedCheese.width / 2,
                y = 0
            },
            speed = {
                x = 0,
                y = 0
            },
            rotation = 0,
            texture = loadedImages.slicedCheese,
            unAnchored = true,
            floorPoint = 1100,
            dragRadius = 100
        }
    },
    slicedCheese = {
        type = "image",
        position = {
            x = screenWidth / 8 - loadedImages.slicedCheese.width / 2,
            y = 0
        },
        speed = {
            x = 0,
            y = 0
        },
        rotation = 0,
        texture = loadedImages.slicedCheese,
        unAnchored = true,
        floorPoint = 1105,
        dragRadius = 100
    },
    fryingPan = {
        type = "image",
        position = {
            x = screenWidth / 1.5 - loadedImages.fryingPan.width / 2,
            y = 0
        },
        speed = {
            x = 0,
            y = 0
        },
        rotation = 0,
        texture = loadedImages.fryingPan,
        unAnchored = true,
        floorPoint = 1115,
        dragRadius = 100,
        utensil = true
    },
    mustard = {
        type = "image",
        position = {
            x = screenWidth / 3 - loadedImages.mustard.width / 2,
            y = 0
        },
        speed = {
            x = 0,
            y = 0
        },
        rotation = 0,
        texture = loadedImages.mustard,
        unAnchored = true,
        floorPoint = 1105,
        dragRadius = 100
    }
}

local ingredients = {
    cheese = {
        "Cheese"
    },
    bread = {
        "Bread"
    },
    egg = {
        "Egg"
    },
    mustard = {
        "Mustard"
    }
}

-- for i, v in pairs(templates) do
--     table.insert(objects, v)
-- end

while not rl.WindowShouldClose() do
    rl.UpdateMusicStream(music)
    local knobPosition = {x = 2159, y = 1216}
    if cooldown ~= 0 then
        cooldown = cooldown + 1
        if cooldown == 2 then
            cooldown = 0
        end
    end

    for i, v in pairs(objects) do
        if v.fryingPan then
            for k, o in pairs(objects) do
                if o.position.x > v.position.x and v.position.x + v.texture.width > o.position.x and o.position.y == o.floorPoint and not o.utensil then
                    v.inventory[#v.inventory + 1] = o
                    objects[k] = nil
                    print(v.inventory[1].texture)
                end
            end
            if v.position.x > 1868 and v.position.x < 2457 - v.texture.width / 2 and burning then
                for k, o in pairs(combinations) do
                    local checks = 0
                    for c, t in pairs(o) do
                        if c ~= "result" then
                            for l, a in pairs(v.inventory) do
                                if a.texture == t then
                                    checks = checks + 1
                                end
                            end
                        end
                    end
                    if checks == #o then
                        if v.cookedTime < 200 then
                            v.cookedTime = v.cookedTime + 1
                            break
                        else
                            v.inventory = {
                                {
                                    type = "image",
                                    position = {
                                        x = screenWidth / 8 - o.result.texture.width / 2,
                                        y = 0
                                    },
                                    speed = {
                                        x = 0,
                                        y = 0
                                    },
                                    rotation = 0,
                                    texture = o.result.texture,
                                    unAnchored = true,
                                    floorPoint = o.result.floorPoint,
                                    dragRadius = o.result.dragRadius
                                }
                            }
                        end
                    end
                end
            end
        end
    end

    for i, v in pairs(objects) do
        if v.unAnchored then
            v["lastPos"] = {v.position.x, v.position.y}
            v.position.x = v.position.x + v.speed.x
            v.position.y = v.position.y + v.speed.y
            v.speed.y = v.speed.y + 1
            if v.position.y > v.floorPoint then
                v.unAnchored = false
                v.speed.y = 0
                v.position.y = v.floorPoint
            end

            if v.mustard then
                for k, o in pairs(objects) do
                    if o.bread and distance(v.position.x, v.position.y, o.position.x, o.position.y) < o.dragRadius then
                        objects[i] = nil
                        o.texture = loadedImages.mustardBread
                    end
                end
            end
        end
    end

    for i, v in pairs(objects) do
        if rl.IsMouseButtonPressed(0) and v.dragRadius then
            if distance(rl.GetMousePosition().x, rl.GetMousePosition().y,
            v.position.x, v.position.y) < v.dragRadius then
                dragging = i
                if dragging ~= "knife" and objects[dragging].returnRotation then
                    objects[dragging].rotation = 90
                end
                if v.locked then
                    objects[dragging].rotation = 0
                end
                break
            end
        end
        if rl.IsMouseButtonReleased(0) and dragging then
            if dragging ~= "knife" and objects[dragging].returnRotation then
                objects[dragging].rotation = objects[dragging].returnRotation
            end
            if not objects[dragging].locked then
                objects[dragging].unAnchored = true
            else
                objects[dragging].position.x = objects[dragging].returnPos.x
                objects[dragging].position.y = objects[dragging].returnPos.y
                objects[dragging].rotation = objects[dragging].returnRotation
            end
            objects[dragging].speed.x = 0
            objects[dragging].speed.y = 0
            dragging = nil
            break
        end
    end

    if dragging then
        objects[dragging].position.x = rl.GetMousePosition().x
        objects[dragging].position.y = rl.GetMousePosition().y

        if objects[dragging].rightClickedFunction and rl.IsMouseButtonPressed(1) then
            objects[dragging]:rightClickedFunction()
            if objects[dragging].rightClickedAdded then
                objects[dragging].rightClickedAdded = objects[dragging].inventory
                for i, v in pairs(objects[dragging].rightClickedAdded) do
                    v.position.x = objects[dragging].position.x
                    v.position.y = objects[dragging].position.y
                    objects[#objects + 1] = v
                end
            end
            if objects[dragging].removeOnRightClick then
                local oldDragging = dragging
                dragging = nil
                objects[oldDragging] = nil
            end
        end
        if dragging == "knife" then
            for i, v in pairs(objects) do
                if distance(objects[dragging].position.x, objects[dragging].position.y,
                v.position.x, v.position.y) < objects.knife.dragRadius and v.sliceable then
                    local sliced = v.sliced
                    local pos = v.position                    
                    objects[i] = nil
                    -- table.insert(objects, templates[v.sliced])
                    objects[#objects + 1] = sliced
                    objects[#objects].position = pos
                end
            end
        end
    end

    if rl.IsMouseButtonPressed(0) and not dragging then
        if distance(rl.GetMousePosition().x, rl.GetMousePosition().y,
        knobPosition.x, knobPosition.y) < 50 then
            burning = not burning
            if burning then
                objects[1].texture = loadedImages.kitchenHot
            else
                objects[1].texture = loadedImages.kitchen
            end
        end
    end

    if rl.IsMouseButtonPressed(0) and not dragging then
        for i, v in pairs(objects) do
            if v.clicked and distance(rl.GetMousePosition().x, rl.GetMousePosition().y,
            v.position.x + v.texture.width / 4, v.position.y - v.texture.height / 4) < v.clickRadius and cooldown == 0 then
                cooldown = 1
                v:clicked()
                if not v["menuText"] then
                    if v.clickedAdded and objects["menu"] then
                        for k, o in pairs(objects) do
                            if o.menuText then
                                objects[k] = nil
                            end
                        end
                        objects["menu"] = nil
                    elseif v.clickedAdded and not objects["menu"] then
                        objects["menu"] = v.clickedAdded
                        if v.clickedAdded.ingredients then
                            local count = 0

                            for k, o in pairs(ingredients) do
                                objects[#objects + 1] = {
                                    type = "text",
                                    position = {
                                        x = objects["menu"].position.x + 50 - objects["menu"].texture.width,
                                        y = 480 + ((count) * 180)
                                    },
                                    textSize = 150,
                                    text = o[1],
                                    color = rl.WHITE,
                                    menuText = true
                                }
                                objects[#objects + 1] = {
                                    type = "image",
                                    position = {
                                        x = loadedImages.menuBackground.width - loadedImages.smallButton.width + objects.menu.position.x,
                                        y = 530 + (150 / 2) + ((count) * 180)
                                    },
                                    rotation = 0,
                                    texture = loadedImages.smallButton,
                                    menuText = true,
                                    clicked = function()

                                    end,
                                    clickedAdded = k,
                                    clickRadius = 100
                                }
                                count = count + 1
                            end
                        end
                    end
                else
                    if v.clickedAdded then
                        if v.clickedAdded == "cheese" then
                            objects[#objects + 1] = {
                                type = "image",
                                position = {
                                    x = screenWidth / 2 - loadedImages.cheese.width / 2,
                                    y = 0
                                },
                                speed = {
                                    x = 0,
                                    y = 0
                                },
                                rotation = 0,
                                texture = loadedImages.cheese,
                                unAnchored = true,
                                floorPoint = 1100,
                                dragRadius = 100,
                                sliceable = true,
                                sliced = {
                                    type = "image",
                                    position = {
                                        x = screenWidth / 8 - loadedImages.slicedCheese.width / 2,
                                        y = 0
                                    },
                                    speed = {
                                        x = 0,
                                        y = 0
                                    },
                                    rotation = 0,
                                    texture = loadedImages.slicedCheese,
                                    unAnchored = true,
                                    floorPoint = 1100,
                                    dragRadius = 100
                                }
                            }
                        elseif v.clickedAdded == "bread" then
                            objects[#objects + 1] = {
                                type = "image",
                                position = {
                                    x = screenWidth / 9 - loadedImages.bread.width / 2,
                                    y = 0
                                },
                                speed = {
                                    x = 0,
                                    y = 0
                                },
                                rotation = 0,
                                texture = loadedImages.bread,
                                unAnchored = true,
                                floorPoint = 1095,
                                dragRadius = 100,
                                sliceable = true,
                                sliced = {
                                    type = "image",
                                    position = {
                                        x = screenWidth / 8 - loadedImages.slicedBread.width / 2,
                                        y = 0
                                    },
                                    speed = {
                                        x = 0,
                                        y = 0
                                    },
                                    rotation = 0,
                                    texture = loadedImages.slicedBread,
                                    unAnchored = true,
                                    floorPoint = 1125,
                                    dragRadius = 100,
                                    bread = true
                                }
                            }
                        elseif v.clickedAdded == "egg" then
                            objects[#objects + 1] = {
                                type = "image",
                                position = {
                                    x = screenWidth / 2.5 - loadedImages.egg.width / 2,
                                    y = 0
                                },
                                speed = {
                                    x = 0,
                                    y = 0
                                },
                                rotation = 0,
                                texture = loadedImages.egg,
                                unAnchored = true,
                                floorPoint = 1110,
                                dragRadius = 100,
                                rightClickedFunction = function(self)
                                    objects[#objects + 1] = {
                                        type = "rectangle",
                                        position = {
                                            x = self.position.x,
                                            y = self.position.y
                                        },
                                        scale = {
                                            x = 50,
                                            y = 20
                                        },
                                        speed = {
                                            x = 0,
                                            y = 0
                                        },
                                        rotation = 0,
                                        texture = loadedImages.slicedCheese,
                                        unAnchored = true,
                                        floorPoint = 1115,
                                        dragRadius = 100,
                                        color = rl.YELLOW
                                    }
                                end,
                                removeOnRightClick = true
                            }
                        elseif v.clickedAdded == "mustard" then
                            objects[#objects + 1] = {
                                type = "image",
                                position = {
                                    x = screenWidth / 3 - loadedImages.mustard.width / 2,
                                    y = 0
                                },
                                speed = {
                                    x = 0,
                                    y = 0
                                },
                                rotation = 0,
                                returnRotation = 0,
                                texture = loadedImages.mustard,
                                unAnchored = true,
                                floorPoint = 1080,
                                dragRadius = 100,
                                rightClickedFunction = function(self)
                                    objects[#objects + 1] = {
                                        type = "rectangle",
                                        position = {
                                            x = self.position.x,
                                            y = self.position.y
                                        },
                                        scale = {
                                            x = 20,
                                            y = 20
                                        },
                                        speed = {
                                            x = 0,
                                            y = 0
                                        },
                                        rotation = 0,
                                        texture = loadedImages.slicedCheese,
                                        unAnchored = true,
                                        floorPoint = 1115,
                                        dragRadius = 100,
                                        color = rl.YELLOW,
                                        mustard = true
                                    }
                                end
                            }
                        end
                    end
                end
                
                -- if v.clickedAdded and not objects["menu"] then
                --     objects["menu"] = v.clickedAdded
                --     if v.clickedAdded.ingredients then
                --         local count = 0

                --         for k, o in pairs(ingredients) do
                --             table.insert(objects, {
                --                 type = "text",
                --                 position = {
                --                     x = objects["menu"].position.x + 50,
                --                     y = 450 + ((count) * 180)
                --                 },
                --                 textSize = 150,
                --                 text = o,
                --                 color = rl.WHITE,
                --                 menuText = true
                --             })
                --             count = count + 1
                --         end
                --     end
                -- end
            end
        end
    end

    rl.BeginDrawing()
    rl.ClearBackground(rl.RAYWHITE)
    for i, v in pairs(objects) do
        if not v.utensil and i ~= "menu" and not v.menuText then
            if v.type == "image" then
                rl.DrawTexturePro(v.texture, {0, 0, v.texture.width, v.texture.height},
                {v.position.x, v.position.y, v.texture.width * 2, v.texture.height * 2},
                {v.texture.width, v.texture.height}, v.rotation, rl.WHITE)
                -- if v.texture == loadedImages.slicedCheese then
                --     print(i, "h", v.position.x, v.position.y)
                -- end
            elseif v.type == "text" then
                rl.DrawText(v.text, v.position.x, v.position.y, v.textSize, v.color)
            elseif v.type == "rectangle" then
                rl.DrawRectanglePro({v.position.x, v.position.y, v.scale.x, v.scale.y}, {0, 0},
                v.rotation, v.color)
            end
        end
    end
    for i, v in pairs(objects) do
        if v.utensil and i ~= "menu" and not v.menuText then
            if v.type == "image" then
                rl.DrawTexturePro(v.texture, {0, 0, v.texture.width, v.texture.height},
                {v.position.x, v.position.y, v.texture.width * 2, v.texture.height * 2},
                {v.texture.width, v.texture.height}, v.rotation, rl.WHITE)
                -- if v.texture == loadedImages.slicedCheese then
                --     print(i, "h", v.position.x, v.position.y)
                -- end
            elseif v.type == "text" then
                rl.DrawText(v.text, v.position.x, v.position.y, v.textSize, v.color)
            elseif v.type == "rectangle" then
                rl.DrawRectanglePro({v.position.x, v.position.y, v.scale.x, v.scale.y}, {0, 0},
                v.rotation, v.color)
            end
        end
    end
    if objects["menu"] then
        -- rl.DrawRectanglePro({objects.menu.position.x, objects.menu.position.y,
        -- objects.menu.scale.x, objects.menu.scale.y}, {0, 0},
        -- objects.menu.rotation, objects.menu.color)
        rl.DrawTexturePro(objects.menu.texture, {0, 0, objects.menu.texture.width, objects.menu.texture.height},
                {objects.menu.position.x, objects.menu.position.y, objects.menu.texture.width * 2, objects.menu.texture.height * 2},
                {objects.menu.texture.width, objects.menu.texture.height}, objects.menu.rotation, rl.WHITE)
    end
    for i, v in pairs(objects) do
        if v.menuText then
            if v.type == "image" then
                rl.DrawTexturePro(v.texture, {0, 0, v.texture.width, v.texture.height},
                {v.position.x, v.position.y, v.texture.width * 2, v.texture.height * 2},
                {v.texture.width, v.texture.height}, v.rotation, rl.WHITE)
                -- if v.texture == loadedImages.slicedCheese then
                --     print(i, "h", v.position.x, v.position.y)
                -- end
            elseif v.type == "text" then
                rl.DrawText(v.text, v.position.x, v.position.y, v.textSize, v.color)
            elseif v.type == "rectangle" then
                rl.DrawRectanglePro({v.position.x, v.position.y, v.scale.x, v.scale.y}, {0, 0},
                v.rotation, v.color)
            end
        end
    end
    rl.EndDrawing()
end

rl.CloseWindow()