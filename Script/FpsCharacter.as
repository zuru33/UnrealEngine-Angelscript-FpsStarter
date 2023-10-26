// Copyright Epic Games, Inc. All Rights Reserved.

class AFpsCharacter : ACharacter {

	UPROPERTY(DefaultComponent, Attach = FirstPersonCameraComponent, VisibleDefaultsOnly, Category=Mesh)
	USkeletalMeshComponent Mesh1P;

	UPROPERTY(DefaultComponent)
	UEnhancedInputComponent InputComponent;

	UPROPERTY(DefaultComponent,VisibleAnywhere, BlueprintReadOnly, Category = Camera, meta = (AllowPrivateAccess = "true")) // Attach = CapsuleComponent
	UCameraComponent FirstPersonCameraComponent;

	UPROPERTY( BlueprintReadOnly, Category=Input, meta=(AllowPrivateAccess = "true"))
	UInputMappingContext DefaultMappingContext;

	UPROPERTY( BlueprintReadOnly, Category=Input, meta=(AllowPrivateAccess = "true"))
	UInputAction JumpAction;

	UPROPERTY( BlueprintReadOnly, Category=Input, meta=(AllowPrivateAccess = "true"))
	UInputAction MoveAction;

	UPROPERTY( BlueprintReadOnly, Category=Input, meta = (AllowPrivateAccess = "true"))
	UInputAction LookAction;

	/** Bool for AnimBP to switch to another animation set */
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = Weapon)
	bool bHasRifle;

	// Character doesnt have a rifle at start
	default bHasRifle = false;

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		// FirstPersonCameraComponent = Cast<UCameraComponent>(CreateComponent(UCameraComponent::StaticClass(), n"FirstPersonCamera"));
		FirstPersonCameraComponent.AttachToComponent(CapsuleComponent);

		// APlayerController PlayerController = Cast<APlayerController>(GetOwner());
	}
	
	// Set size for collision capsule	
	default CapsuleComponent.SetCapsuleSize(55.f, 96.0f);
		
	// Create a CameraComponent	
	default FirstPersonCameraComponent.SetRelativeLocation(FVector(-10.f, 0.f, 60.f)); // Position the camera
	default FirstPersonCameraComponent.bUsePawnControlRotation = true;

	// Create a mesh component that will be used when being viewed from a '1st person' view (when controlling this pawn)
	default Mesh1P.SetOnlyOwnerSee(true);
	default Mesh1P.bCastDynamicShadow = false;
	default Mesh1P.CastShadow = false;
	//default Mesh1P.SetRelativeRotation(FRotator(0.9f, -19.19f, 5.2f));
	default Mesh1P.SetRelativeLocation(FVector(-30.f, 0.f, -150.f));

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Controller is nullptr in ConstructionScript(), but is valid in BeginPlay(), so this is the proper place to init this I guess.
		auto PlayerController = Cast<APlayerController>(Controller);
        // PlayerController.PushInputComponent(InputComponent); // Already connected to PlayerController for some reason. Don't do this or your events will fire twice.
		SetupPlayerInputComponent(InputComponent);

		//Add Input Mapping Context
		if (PlayerController != nullptr)
		{
			auto Subsystem = UEnhancedInputLocalPlayerSubsystem::Get(PlayerController.GetLocalPlayer());
			check(Subsystem != nullptr);
			if (Subsystem != nullptr)
			{
				Subsystem.AddMappingContext(DefaultMappingContext, 0, FModifyContextOptions());
			}
		}

	}

	//////////////////////////////////////////////////////////////////////////// Input

	void SetupPlayerInputComponent(UEnhancedInputComponent EnhancedInputComponent)
	{
		// Set up action bindings
		//Jumping
		FEnhancedInputActionHandlerDynamicSignature JumpTriggered;
		JumpTriggered.BindUFunction(this, n"JumpTriggered");
		EnhancedInputComponent.BindAction(JumpAction, ETriggerEvent::Triggered, JumpTriggered);
		
		FEnhancedInputActionHandlerDynamicSignature JumpCompleted;
		JumpCompleted.BindUFunction(this, n"JumpCompleted");
		EnhancedInputComponent.BindAction(JumpAction, ETriggerEvent::Completed, JumpCompleted);

		//Moving
		FEnhancedInputActionHandlerDynamicSignature Move;
		Move.BindUFunction(this, n"Move");
		EnhancedInputComponent.BindAction(MoveAction, ETriggerEvent::Triggered, Move);

		//Looking
		FEnhancedInputActionHandlerDynamicSignature Look;
		Look.BindUFunction(this, n"Look");
		EnhancedInputComponent.BindAction(LookAction, ETriggerEvent::Triggered, Look);
	}

	UFUNCTION(BlueprintCallable)
	void JumpTriggered(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		Jump();
	}

	UFUNCTION(BlueprintCallable)
	void JumpCompleted(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		StopJumping();
	}

	UFUNCTION()
	void Move(const FInputActionValue Value, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		// input is a Vector2D
		// FVector2D MovementVector = Value.Get<FVector2D>();
		FVector2D MovementVector = Value.Axis2D;

		if (Controller != nullptr)
		{
			// add movement 
			AddMovementInput(GetActorForwardVector(), MovementVector.Y);
			AddMovementInput(GetActorRightVector(), MovementVector.X);
		}
	}

	UFUNCTION()
	void Look(const FInputActionValue Value, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		// input is a Vector2D
		// FVector2D LookAxisVector = Value.Get<FVector2D>();
		FVector2D LookAxisVector = Value.Axis2D;

		if (Controller != nullptr)
		{
			// add yaw and pitch input to controller
			AddControllerYawInput(LookAxisVector.X);
			AddControllerPitchInput(LookAxisVector.Y);
		}
	}

	UFUNCTION(BlueprintCallable, Category = Weapon)
	void SetHasRifle(bool bNewHasRifle)
	{
		bHasRifle = bNewHasRifle;
	}

	UFUNCTION(BlueprintCallable, Category = Weapon)
	bool GetHasRifle()
	{
		return bHasRifle;
	}	

	/** Returns Mesh1P subobject **/
	USkeletalMeshComponent GetMesh1P() const { return Mesh1P; }

	/** Returns FirstPersonCameraComponent subobject **/
	UCameraComponent GetFirstPersonCameraComponent() const { return FirstPersonCameraComponent; }
}