
class AFpsPlayerController : APlayerController {
    UPROPERTY(BlueprintReadOnly, Category = Input)
	UInputMappingContext InputMappingContext;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // get the enhanced input subsystem
        auto Subsystem = UEnhancedInputLocalPlayerSubsystem::Get(GetLocalPlayer());
        check(Subsystem != nullptr);
        if (Subsystem != nullptr)
        {
            // add the mapping context so we get controls
            Subsystem.AddMappingContext(InputMappingContext, 0, FModifyContextOptions());
            Print("BeginPlay");
        }
    }
}