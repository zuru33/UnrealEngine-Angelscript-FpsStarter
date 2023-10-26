// Copyright Epic Games, Inc. All Rights Reserved.

event void FOnPickUp_AS(AFpsCharacter PickUpCharacter);

class UTP_PickUpComponent_AS : USphereComponent {
	UPROPERTY(Category = "Interaction")
	FOnPickUp_AS OnPickUp;

	// Setup the Sphere Collision
	float SphereRadius = 32.f;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Register our Overlap Event
		OnComponentBeginOverlap.AddUFunction(this, n"OnSphereBeginOverlap");
	}

	// UFUNCTION(BlueprintEvent)
	// void OnPickUp()
	// {
	// }

	UFUNCTION()
	void OnSphereBeginOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
	{
		// Checking if it is a First Person Character overlapping
		AFpsCharacter Character = Cast<AFpsCharacter>(OtherActor);
		if(Character != nullptr)
		{
			// Notify that the actor is being picked up
			OnPickUp.Broadcast(Character);

			// Unregister from the Overlap Event so it is no longer triggered
			OnComponentBeginOverlap.UnbindObject(this);
		}
	}

}