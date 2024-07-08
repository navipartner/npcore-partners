codeunit 6059929 "NPR Price Source - Store Group" implements "Price Source"
{
    Access = Internal;

    var
        POSStoreGroup: Record "NPR POS Store Group";
        ParentErr: Label 'Parent Source No. must be blank for Store source type.';

    procedure GetNo(var PriceSource: Record "Price Source")
    begin
        if POSStoreGroup.GetBySystemId(PriceSource."Source ID") then begin
            PriceSource."Source No." := POSStoreGroup."No.";
#IF NOT BC17
            FillAdditionalFields(PriceSource);
#ENDIF
        end else
            PriceSource.InitSource();
    end;

    procedure GetId(var PriceSource: Record "Price Source")
    begin
        if POSStoreGroup.Get(PriceSource."Source No.") then begin
            PriceSource."Source ID" := POSStoreGroup.SystemId;
#IF NOT BC17
            FillAdditionalFields(PriceSource);
#ENDIF
        end else
            PriceSource.InitSource();
    end;

    procedure IsForAmountType(AmountType: Enum "Price Amount Type"): Boolean
    begin
        exit(true);
    end;

    procedure IsLookupOK(var PriceSource: Record "Price Source"): Boolean
    var
        xPriceSource: Record "Price Source";
    begin
        xPriceSource := PriceSource;
        if POSStoreGroup.Get(xPriceSource."Source No.") then;
        if Page.RunModal(0, POSStoreGroup) = ACTION::LookupOK then begin
            xPriceSource.Validate("Source No.", POSStoreGroup."No.");
            PriceSource := xPriceSource;
            exit(true);
        end;
    end;

    procedure VerifyParent(var PriceSource: Record "Price Source") Result: Boolean
    begin
        if PriceSource."Parent Source No." <> '' then
            Error(ParentErr);
    end;

    procedure IsSourceNoAllowed() Result: Boolean
    begin
        Result := true;
    end;

    procedure GetGroupNo(PriceSource: Record "Price Source"): Code[20]
    begin
        exit(PriceSource."Source No.");
    end;

#IF NOT BC17
    local procedure FillAdditionalFields(var PriceSource: Record "Price Source")
    begin
        PriceSource.Description := POSStoreGroup.Description;
    end;
#ENDIF
}
