-- Wired via entity_AutoButterChurn.txt's component SpriteConfig { OnCreate = ... }.
-- Fires once, right after the BUILD-menu recipe constructs the entity's
-- IsoThumpable, on both client and server.
--
-- Note the component: ISBuildIsoEntity.lua's post-build hook call is
-- self.objectInfo:getScript():getOnCreate() - ObjectInfo:getScript() returns
-- the entity's SpriteConfigScript (zombie42_20_4/entity/components/spriteconfig/
-- SpriteConfigManager.java:401), a different accessor from ObjectInfo:getRecipe()
-- (line 405, the CraftRecipeComponentScript). An OnCreate field placed inside
-- component CraftRecipe (DC2 Phase 7's first attempt) is never read by this
-- placement path at all - it silently never fires. It has to live in
-- component SpriteConfig instead (DC2 Phase 10).

AutoButterChurnBuildHooks = {}

-- Confirmed visible in-game (DC1 Phase 16) - this is vanilla ChurnBucket's own
-- declared sprite (entity_butter_churn.txt). Declaring it directly in this
-- entity's own component SpriteConfig collides with ChurnBucket's declaration
-- (DC1 Phase 7; DC2 Phase 5 Bug 2 hit the identical collision again) because
-- SpriteConfigManager checks declared SpriteConfig rows for global uniqueness
-- across every entity script. Setting it here instead - directly onto the
-- freshly-built IsoThumpable via IsoThumpable:setSprite(), which just updates
-- the live sprite/closedSprite fields with no uniqueness check at all - avoids
-- that check entirely. This is the same bypass DC1 used successfully via
-- addWorkstationEntity's runtime sprite argument (DC1 Phase 16), adapted to
-- this cycle's BUILD-menu placement.
AutoButterChurnBuildHooks.WORLD_SPRITE = "crafted_05_72"

function AutoButterChurnBuildHooks.onCreate(_params)
    local thumpable = _params and _params.thumpable
    if thumpable then
        thumpable:setSprite(AutoButterChurnBuildHooks.WORLD_SPRITE)
    end
end
