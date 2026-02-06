table 6059866 "NPR TM TempTicketDescription"
{
    DataClassification = CustomerContent;
    TableType = Temporary;
    Caption = 'Ticket Description';
    Access = Internal;

    fields
    {
        field(1; ItemNo; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(2; VariantCode; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(3; AdmissionCode; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
        }
        field(4; LanguageCode; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
        }
        field(10; Title; Text[2048])
        {
            Caption = 'Title';
            DataClassification = CustomerContent;
        }
        field(11; Subtitle; Text[2048])
        {
            Caption = 'Subtitle';
            DataClassification = CustomerContent;
        }
        field(12; Name; Text[2048])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(13; Description; Text[2048])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(14; FullDescription; Text[2048])
        {
            Caption = 'Full Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; ItemNo, VariantCode, AdmissionCode)
        {
        }
    }

    // AA0245 enabled on cloud builds, so lets go hungarian ...
    internal procedure SetKeyAndDescription(pItemNo: Code[20]; pVariantCode: Code[10]; pAdmissionCode: Code[20]; StoreCode: Code[32]; pLanguageCode: Code[10])
    begin
        Clear(Rec);
        Rec.ItemNo := pItemNo;
        Rec.VariantCode := pVariantCode;
        Rec.AdmissionCode := pAdmissionCode;

        SetDescription(pItemNo, pVariantCode, pAdmissionCode, StoreCode, pLanguageCode);
    end;

    internal procedure SetDescription(pItemNo: Code[20]; pVariantCode: Code[10]; pAdmissionCode: Code[20]; StoreCode: Code[32]; pLanguageCode: Code[10])
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        DescriptionContext: Codeunit "NPR TMTicketDescriptions";
    begin
        if (Rec.LanguageCode <> pLanguageCode) then begin
            Rec.SetRecFilter();
            if (not Rec.Delete()) then;
        end;

        DescriptionContext.Initialize(pItemNo, pVariantCode, pAdmissionCode, StoreCode, pLanguageCode);

        Rec.Title := CopyStr(DescriptionContext.GetDescription(TicketSetup.FieldNo("Ticket Title")), 1, MaxStrLen(Rec.Title));
        Rec.Subtitle := CopyStr(DescriptionContext.GetDescription(TicketSetup.FieldNo("Ticket Sub Title")), 1, MaxStrLen(Rec.Subtitle));
        Rec.Name := CopyStr(DescriptionContext.GetDescription(TicketSetup.FieldNo("Ticket Name")), 1, MaxStrLen(Rec.Name));
        Rec.Description := CopyStr(DescriptionContext.GetDescription(TicketSetup.FieldNo("Ticket Description")), 1, MaxStrLen(Rec.Description));
        Rec.FullDescription := CopyStr(DescriptionContext.GetDescription(TicketSetup.FieldNo("Ticket Full Description")), 1, MaxStrLen(Rec.FullDescription));

        Rec.LanguageCode := pLanguageCode;
    end;
}