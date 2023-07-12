tableextension 6014456 "NPR Item Unit Of Measure" extends "Item Unit of Measure"
{
    fields
    {
        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }

        field(6151480; "NPR Block on POS Sale"; Boolean)
        {
            Caption = 'Block on POS Sale';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                NPRPOSIUOMUtils: Codeunit "NPR POS IUOM Utils";
            begin
                if Rec."NPR Block on POS Sale" <> xRec."NPR Block on POS Sale" then
                    NPRPOSIUOMUtils.CheckIfBlockingBaseUOM(Rec);
            end;
        }
    }

    keys
    {
        key("NPR Key1"; "NPR Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key("NPR Key2"; SystemRowVersion)
        {
        }
#ENDIF
    }
}
