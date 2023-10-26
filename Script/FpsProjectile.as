// Copyright Epic Games, Inc. All Rights Reserved.

class AFpsProjectile : AActor
{
	/** Sphere collision component */
	UPROPERTY(DefaultComponent, VisibleDefaultsOnly, Category=Projectile)
	USphereComponent CollisionComp; // name = "SphereComp"

	/** Projectile movement component */
	UPROPERTY(DefaultComponent, VisibleAnywhere, BlueprintReadOnly, Category = Movement, meta = (AllowPrivateAccess = "true"))
	UProjectileMovementComponent ProjectileMovement; // name = ProjectileComp

	// Use a sphere as a simple collision representation
	default CollisionComp.SetSphereRadius(5.0f);
	default CollisionComp.SetCollisionProfileName(n"Projectile");
	default CollisionComp.OnComponentHit.AddUFunction(this, n"OnHit");		// set up a notification for when this component hits something blocking

	// Players can't walk on it
	default CollisionComp.CanCharacterStepUpOn = ECanBeCharacterBase::ECB_No;

	// Set as root component
	default RootComponent = CollisionComp;

	// Use a ProjectileMovementComponent to govern this projectile's movement
	default ProjectileMovement.UpdatedComponent = CollisionComp;
	default ProjectileMovement.InitialSpeed = 3000.f;
	default ProjectileMovement.MaxSpeed = 3000.f;
	default ProjectileMovement.bRotationFollowsVelocity = true;
	default ProjectileMovement.bShouldBounce = true;

	// Die after 3 seconds by default
	default InitialLifeSpan = 3.0f;

	UFUNCTION(BlueprintOverride)
	void ConstructionScript()
	{
		FWalkableSlopeOverride WalkableSlope;
		WalkableSlope.WalkableSlopeAngle = 0.f;
		WalkableSlope.WalkableSlopeBehavior = EWalkableSlopeBehavior::WalkableSlope_Unwalkable;
		CollisionComp.SetWalkableSlopeOverride(WalkableSlope);
	}

	UFUNCTION()
	void OnHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		// Only add impulse and destroy projectile if we hit a physics
		if ((OtherActor != nullptr) && (OtherActor != this) && (OtherComp != nullptr) && OtherComp.IsSimulatingPhysics())
		{
			OtherComp.AddImpulseAtLocation(GetVelocity() * 100.0f, GetActorLocation());

			DestroyActor();
		}
	}

	/** Returns CollisionComp subobject **/
	USphereComponent GetCollisionComp() const { return CollisionComp; }
	
	/** Returns ProjectileMovement subobject **/
	UProjectileMovementComponent GetProjectileMovement() const { return ProjectileMovement; }

}