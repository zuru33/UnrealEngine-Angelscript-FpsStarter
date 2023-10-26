# Unreal AngelScript FPS Starter Template

This code is for the awesome [Unreal Engine Angelscript](https://github.com/Hazelight/UnrealEngine-Angelscript) fork of Unreal. You must have Unreal source access to use Unreal-Angelscript. See the [official site](https://angelscript.hazelight.se/) for documentation on getting started with AngelScript in Unreal.

See the below instructions for replacing the FPS Starter C++ code with this AngelScript code.

# Why AngelScript?

AngelScript is a lot simpler and faster to work with than C++. It also supports hot reloading like Blueprints.

# How to use these files in your project
1. Open Unreal-Angelscript 5.x, and generate an FPS template project in C++. Do not name your project "Fps", or that will conflict with this example code.
1. Once it finishes generating, run your FPS project and make sure it runs correctly.
1. In Unreal, Edit > Plugins > Install "Enhanced Input support for Angelscript" plugin.
1. Copy these .as files into your ProjectName/Script folder.
1. Make copies of the FPS starter blueprints, and update them to use the AngelScript files instead:
    1. Make a blueprint that inherits from FpsGameMode, and delete the ConstructionScript to convert it to a data only blueprint. Edit it so that the Character class is FpsCharacter, and the Controller class is FpsPlayerController. Then edit the Unreal Project Settings and set this as the default game mode, and also set this as the game mode for FirstPersonMap too (in Outliner, right click FirstPersonMap > World Settings > update GameMode Override).
    1. Make copies of blueprints BP_FirstPersonCharacter, BP_FirstPersonGameMode, BP_FirstPersonPlayerController, BP_FirstPersonProjectile, BP_Pickup_Rifle, and change the parent class of these blueprints to use the AngelScript versions of these classes ("Class Settings" Button in Blueprint editor > Parent Class), and update and/or recreate components to use the AngelScript versions of these classes as well.
    1. You will need to recreate the event graph for BP_Pickup_Rifle_YourCopy using the AngelScript versions of these nodes. In the blueprint editor for this, under variables > TP_PickUpComponent_YourCopy > in the details panel, add "On Pick Up AS". And then call Attach Weapon for "TP Weapon Component AS". Make sure TP_WeaponComponent_AS has the same properties set as BP_Pickup_rifle's TP_WeaponComponent. It should have Fire Mapping Context, Fire Action, and Skeleton Mesh Asset set to the same assets. Projectile Class should be set to BP_FirstPersonProjectile_YourCopy.
    1. Place your modified PickupComponent on the map. Run the game and see if you can pick up your AngelScript version of the weapon and shoot. If you can't shoot or pick it up, the game Character could be the old C++ version, and the cast in TP_PickUpComponent_AS.as OnSphereBeginOverlap is failing. This will happen if the game is using the wrong game mode. Double check FirstPersonMap that it is using the AngelScript game mode, and that the Project Settings are also using your game mode.
    1. Update FirstPerson_AnimBP to use the new AngelScript types. The FirstPersonCharacter variable needs to be updated, as well as a couple casts and variable gets and sets.
1. Try adding a `Print("Hello World");` in each AS file, and make sure it shows up when you run the game.
1. If you want to remove the C++ versions of these files from your project, you can do so as follows:
    1. In the Unreal content browser, make sure there are no references to the old C++ files. Try to delete the original Starter FPS blueprints, and it will tell you which blueprints need to be updated.
    1. Close Unreal editor.
    1. In your Visual Studio project > Games folder, delete the C++ files the above blueprints were referencing.
    1. In Visual Studio > Games folder > right click your ProjectName > Clean.
    1. Close and re-open Visual Studio > Games folder > right click your ProjectName > Build.
    1. Open your project in Unreal Editor, and see if it opens without errors. If there are missing class errors, you may need to edit DefaultEngine.ini > [CoreRedirects] and redirect missing classes to your AngelScript classes.

# Learnings about AngelScript unreal
Only Blueprint-exposed C++ classes are available to AngelScript. Compare [AngelScript API docs](https://angelscript.hazelight.se/api) vs. [Unreal C++ API](https://www.unrealengine.com/en-US/search?filter=C%2B%2B%20API&keyword=). If you do not have access to a certain C++ API, try to use the existing AngelScript APIs available to you. If you need, you can [expose the C++ API to AngelScript](https://discord.com/channels/551756549962465299/551756549962465303/989270666245206027).

You cannot call overriden C++ `Super::` functions like `Super::BeginPlay()` (see [docs](https://angelscript.hazelight.se/project/development-status/)).