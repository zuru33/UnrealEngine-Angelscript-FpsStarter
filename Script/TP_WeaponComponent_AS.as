// Copyright Epic Games, Inc. All Rights Reserved.

class UTP_WeaponComponent_AS : USkeletalMeshComponent {

	/** The Character holding this weapon */
	private AFpsCharacter Character;

	/** Projectile class to spawn */
	UPROPERTY(EditDefaultsOnly, Category=Projectile)
	TSubclassOf<AFpsProjectile> ProjectileClass;

	UPROPERTY(EditDefaultsOnly, Category=Projectile)
	TSubclassOf<AFpsProjectile> ProjectileClass2;

	/** Sound to play each time we fire */
	UPROPERTY(  Category=Gameplay)
	USoundBase FireSound;
	
	/** AnimMontage to play each time we fire */
	UPROPERTY(  Category = Gameplay)
	UAnimMontage FireAnimation;

	/** Gun muzzle's offset from the characters location */
	UPROPERTY(  Category=Gameplay)
	FVector MuzzleOffset;
	// Default offset from the character location for projectiles to spawn
	default MuzzleOffset = FVector(100.0f, 0.0f, 10.0f);

	/** MappingContext */
	UPROPERTY( BlueprintReadOnly, Category=Input, meta=(AllowPrivateAccess = "true"))
	UInputMappingContext FireMappingContext;

	/** Fire Input Action */
	UPROPERTY( BlueprintReadOnly, Category=Input, meta=(AllowPrivateAccess = "true"))
	UInputAction FireAction;


	/** Make the weapon Fire a Projectile */
	UFUNCTION(BlueprintCallable, Category="Weapon")
	void Fire(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		if (Character == nullptr || Character.GetController() == nullptr)
		{
			return;
		}

		// Try and fire a projectile
		if (ProjectileClass != nullptr)
		{
			const UWorld World = GetWorld();
			if (World != nullptr)
			{
				APlayerController PlayerController = Cast<APlayerController>(Character.GetController());
				const FRotator SpawnRotation = PlayerController.PlayerCameraManager.GetCameraRotation();
				// MuzzleOffset is in camera space, so transform it to world space before offsetting from the character location to find the final muzzle position
				const FVector SpawnLocation = GetOwner().GetActorLocation() + SpawnRotation.RotateVector(MuzzleOffset);
		
				// Not exposed to AngelScript, but you can enable this yourself if you edit unreal-angelscript project and build from source.
				// See https://discord.com/channels/551756549962465299/551756549962465303/989270666245206027
				
				// Set Spawn Collision Handling Override
				// FActorSpawnParameters ActorSpawnParams;
				// ActorSpawnParams.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AdjustIfPossibleButDontSpawnIfColliding;
		
				// Spawn the projectile at the muzzle
				// World.SpawnActor<AFpsProjectile>(ProjectileClass, SpawnLocation, SpawnRotation, ActorSpawnParams);

				SpawnActor(ProjectileClass, SpawnLocation, SpawnRotation);
			}
		}
		
		// Try and play the sound if specified
		if (FireSound != nullptr)
		{
			// UGameplayStatistics might be mapped to Gameplay in angelscript apparently?
			// See https://discord.com/channels/551756549962465299/551756549962465303/983735416236679218
			// UGameplayStatics::PlaySoundAtLocation(this, FireSound, Character.GetActorLocation());
			Gameplay::PlaySoundAtLocation(FireSound, Character.GetActorLocation(), Character.ActorRotation);
		}
		
		// Try and play a firing animation if specified
		if (FireAnimation != nullptr)
		{
			// Get the animation object for the arms mesh
			UAnimInstance AnimInstance = Character.GetMesh1P().GetAnimInstance();
			if (AnimInstance != nullptr)
			{
				AnimInstance.Montage_Play(FireAnimation, 1.f);
			}
		}
	}

	/** Attaches the actor to a FirstPersonCharacter */
	UFUNCTION(BlueprintCallable, Category="Weapon")
	void AttachWeapon(AFpsCharacter TargetCharacter)
	{
		Character = TargetCharacter;
		if (Character == nullptr)
		{
			return;
		}

		// Attach the weapon to the First Person Character
		// FAttachmentTransformRules AttachmentRules(EAttachmentRule::SnapToTarget, true);
		AttachToComponent(Character.GetMesh1P(), FName(n"GripPoint"), EAttachmentRule::SnapToTarget, EAttachmentRule::SnapToTarget, EAttachmentRule::SnapToTarget, true);
		
		// switch bHasRifle so the animation blueprint can switch to another animation set
		Character.SetHasRifle(true);

		// Set up action bindings
		APlayerController PlayerController = Cast<APlayerController>(Character.GetController());
		check(PlayerController != nullptr);

		auto Subsystem = UEnhancedInputLocalPlayerSubsystem::Get(PlayerController.GetLocalPlayer());
		check(Subsystem != nullptr);
		if (Subsystem != nullptr)
		{
			// Set the priority of the mapping to 1, so that it overrides the Jump action with the Fire action when using touch input
			Subsystem.AddMappingContext(FireMappingContext, 1, FModifyContextOptions());
		}

		// UEnhancedInputComponent EnhancedInputComponent = Cast<UEnhancedInputComponent>(PlayerController.InputComponent);
		auto EnhancedInputComponent = Character.InputComponent;
		check(EnhancedInputComponent != nullptr);
		if (EnhancedInputComponent != nullptr)
		{
			// Fire
			FEnhancedInputActionHandlerDynamicSignature Fire;
			Fire.BindUFunction(this, n"Fire");
			EnhancedInputComponent.BindAction(FireAction, ETriggerEvent::Triggered, Fire);
		}
	}

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		if (Character == nullptr)
		{
			return;
		}

		APlayerController PlayerController = Cast<APlayerController>(Character.GetController());
		if (PlayerController != nullptr)
		{
			auto Subsystem = UEnhancedInputLocalPlayerSubsystem::Get(PlayerController.GetLocalPlayer());
			if (Subsystem != nullptr)
			{
				Subsystem.RemoveMappingContext(FireMappingContext, FModifyContextOptions());
			}
		}
	}
}