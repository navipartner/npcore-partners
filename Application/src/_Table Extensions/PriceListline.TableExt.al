tableextension 6014459 "NPR Price List line" extends "Price List Line"
{
    fields
    {
        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }

        field(6014400; "NPR Price List Id"; GUID)
        {
            Caption = 'Price List Id';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key("NPR Key1"; "NPR Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key("NPR Key2"; SystemRowVersion)
        {
        }
#ENDIF

    }
    trigger OnBeforeModify()
    begin
        RSRetailLocalizationMgt.RetailCheckForModifyActiveLine(xRec);
    end;

    trigger OnBeforeDelete()
    begin
        RSRetailLocalizationMgt.RetailCheckForDeleteActiveLine(xRec);
    end;

    internal procedure NPR_UpdateReferencedIds()
    var
        PriceListHeader: Record "Price List Header";
    begin
        if "Price List Code" = '' then begin
            Clear("NPR Price List Id");
            exit;
        end;

        if not PriceListHeader.Get(Rec."Price List Code") then
            exit;

        "NPR Price List Id" := PriceListHeader.SystemId;
    end;

    var
        RSRetailLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
}
