table 6059835 "NPR SI Fiscalization Setup"
{
    Access = Internal;
    Caption = 'SI Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR SI Fiscalization Setup";
    LookupPageId = "NPR SI Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Enable SI Fiscal"; Boolean)
        {
            Caption = 'Enable SI Fiscalization';
            DataClassification = CustomerContent;
        }
        field(3; "Receipt No. Series"; Code[20])
        {
            Caption = 'Receipt No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(4; "Environment URL"; Text[2048])
        {
            Caption = 'Environment URL';
            DataClassification = CustomerContent;
        }
        field(10; "Signing Certificate"; Blob)
        {
            Caption = 'Signing Certificate';
            DataClassification = CustomerContent;
        }
        field(11; "Signing Certificate Password"; Text[100])
        {
            Caption = 'Signing Certificate Password';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(12; "Signing Certificate Thumbprint"; Text[250])
        {
            Caption = 'Signing Certificate Thumbprint';
            DataClassification = CustomerContent;
        }
        field(13; "Certificate Serial No."; Text[2048])
        {
            Caption = 'Certificate Serial No.';
            DataClassification = CustomerContent;
        }
        field(14; "Certificate Private Key"; Blob)
        {
            Caption = 'Certificate Private Key';
            DataClassification = CustomerContent;
        }
        field(15; "Certificate Subject Ident."; Code[20])
        {
            Caption = 'Certificate Subject Identification';
            DataClassification = CustomerContent;
        }
        field(20; "Print Receipt On Sales Doc."; Boolean)
        {
            Caption = 'Auto Print Receipt On Sales Document';
            DataClassification = CustomerContent;
        }
        field(21; "Print EFT Information"; Boolean)
        {
            Caption = 'Print EFT Information';
            DataClassification = CustomerContent;
        }
        field(30; "E-Mail Subject"; Text[250])
        {
            Caption = 'E-Mail Subject';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    internal procedure InitSoftwareSupplierInfo(var SoftwareSupplierName: Text; var SoftwareSupplierAddress: Text; var SoftwareSupplierCity: Text)
    begin
        SoftwareSupplierName := SoftwareSupplierNameLbl;
        SoftwareSupplierAddress := SoftwareSupplierAddressLbl;
        SoftwareSupplierCity := SoftwareSupplierCityLbl;
    end;

    internal procedure GetSoftwareSupplierInfo(): Text
    var
        SoftwareSupplierFormatLbl: Label '%1, %2 %3', Locked = true, Comment = '%1 = Name, %2 = Address, %3 = City';
    begin
        exit(StrSubstNo(SoftwareSupplierFormatLbl, SoftwareSupplierNameLbl, SoftwareSupplierAddressLbl, SoftwareSupplierCityLbl));
    end;

    var
        SoftwareSupplierNameLbl: Label 'Navi Partner København ApS', Locked = true;
        SoftwareSupplierAddressLbl: Label 'Hillerødgade 30', Locked = true;
        SoftwareSupplierCityLbl: Label '2200 Frederiksberg, Denmark', Locked = true;
}