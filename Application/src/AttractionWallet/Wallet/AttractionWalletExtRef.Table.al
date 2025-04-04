table 6151146 "NPR AttractionWalletExtRef"
{
    Access = Internal;
    Caption = 'Attraction Wallet External Reference';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ExternalReference; Text[100])
        {
            Caption = 'External Reference';
            DataClassification = CustomerContent;
        }
        field(2; WalletEntryNo; Integer)
        {
            Caption = 'Wallet Id';
            TableRelation = "NPR AttractionWallet".EntryNo;
            DataClassification = SystemMetadata;
        }
        field(3; BlockedAt; DateTime)
        {
            Caption = 'Blocked At';
            DataClassification = SystemMetadata;
        }
        field(4; ExpiresAt; DateTime)
        {
            Caption = 'Expires At';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; ExternalReference)
        {
            Clustered = true;
        }
        key(ByWallet; WalletEntryNo)
        {
        }
        key(ValidReferences; BlockedAt, ExpiresAt)
        {
#if not (BC17 or BC18)
            IncludedFields = WalletEntryNo;
#endif
        }
    }

    var
        _ExtRefAlreadyInUseErr: Label 'The selected external reference is already in use with another wallet. Requested reference: %1', Comment = '%1 = the requested reference';

    trigger OnInsert()
    begin
        CheckIsUnique();
    end;

    trigger OnRename()
    begin
        CheckIsUnique();
    end;

    local procedure CheckIsUnique()
    begin
        if (Rec.IsTemporary()) then
            exit;

        if (not IsUnique()) then
            Error(_ExtRefAlreadyInUseErr, Rec.ExternalReference)
    end;

    local procedure IsUnique(): Boolean
    var
        ExtRef: Record "NPR AttractionWalletExtRef";
        Wallet: Record "NPR AttractionWallet";
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        ExtRef.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
        ExtRef.SetRange(ExternalReference, Rec.ExternalReference);
        if (not ExtRef.IsEmpty()) then
            exit(false);

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        Wallet.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
        Wallet.SetRange(ReferenceNumber, Rec.ExternalReference);
        exit(Wallet.IsEmpty());
    end;
}