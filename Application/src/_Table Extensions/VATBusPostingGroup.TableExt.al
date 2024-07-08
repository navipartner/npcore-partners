tableextension 6014471 "NPR VAT Bus. Posting Group" extends "VAT Business Posting Group"
{
    fields
    {
        field(6014400; "NPR Restricted on POS"; Boolean)
        {
            Caption = 'Restricted on POS';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                POSPostingProfile: Record "NPR POS Posting Profile";
                CannotBeActivatedErr: Label '%1 cannot be set to true in %2 %3=''%4'', because the group is used in one or more POS Posting profiles', Comment = '%1 - fieldcaption, %2 - tablecaption, %3 - primary key field caption, %4 - primary key field value';
            begin
                if Rec."NPR Restricted on POS" then begin
                    POSPostingProfile.SetRange("VAT Bus. Posting Group", Rec.Code);
                    if not POSPostingProfile.IsEmpty then
                        Error(CannotBeActivatedErr, Rec.FieldCaption("NPR Restricted on POS"), Rec.TableCaption, Rec.FieldCaption(Code), Rec.Code);
                end;
            end;
        }
    }
}