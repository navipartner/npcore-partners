table 6014691 "NPR Package Dimension"
{
    Access = public;
    Caption = 'Package Dimensions';
    DataClassification = ToBeClassified;
    DrillDownPageId = "NPR Package Dimensions";
    LookupPageId = "NPR Package Dimensions";


    fields
    {
        field(1; "Document Type"; enum "NPR ShipProviderDocumentType")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Package Code"; Code[20])
        {
            Caption = 'Package Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Package Code".code;
        }
        field(5; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(6; Weight_KG; Decimal)
        {
            Caption = 'Weight_KG';
            DataClassification = CustomerContent;
        }
        field(7; Width; Decimal)
        {
            Caption = 'Width_cm';
            DataClassification = CustomerContent;
            trigger onValidate()
            begin
                CalcVolume()
            end;
        }
        field(8; Length; Decimal)
        {
            Caption = 'Length_cm';
            DataClassification = CustomerContent;
            trigger onValidate()
            begin
                CalcVolume()
            end;
        }
        field(9; Height; Decimal)
        {
            Caption = 'Height_cm';
            DataClassification = CustomerContent;
            trigger onValidate()
            begin
                CalcVolume()
            end;
        }
        field(10; Volume; Decimal)
        {
            Caption = ' Volume cubic metres ';
            DataClassification = CustomerContent;
        }
        field(11; running_metre; Decimal)
        {
            Caption = 'running_metre';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[250])
        {
            Caption = 'Package Description';
            DataClassification = CustomerContent;
        }
        field(21; "Package Amount Incl. VAT"; Decimal)
        {
            Caption = 'Package Amount Incl. VAT';
            DataClassification = CustomerContent;
        }
        field(22; "Package Amount Currency Code"; Code[10])
        {
            Caption = 'Package Amount Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(25; Items; Integer)
        {
            Caption = 'Items';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("NPR Package Dimension Details" where("Document Type" = field("Document Type"), "Document No." = field("Document No."), "Package Dimension Line No." = field("Line No.")));

        }

    }
    keys
    {
        key(PK; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        NPRPackageDimDetails: Record "NPR Package Dimension Details";
    begin
        NPRPackageDimDetails.SetRange("Document Type", "Document Type");
        NPRPackageDimDetails.SetRange("Document No.", "Document No.");
        NPRPackageDimDetails.setrange("Package Dimension Line No.", "Line No.");
        NPRPackageDimDetails.deleteall(true);
    end;

    local procedure CalcVolume()
    begin
        Volume := Length * Width * Height;
    end;
}
