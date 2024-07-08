table 6059865 "NPR NPCamera Profile"
{
    DataClassification = CustomerContent;
    Access = Internal;
    Extensible = false;
    fields
    {
        field(1; "Code"; Code[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; "File Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "PNG","JPEG";
            InitValue = "JPEG";
        }
        field(3; "Quality Option"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Image Jpeg Quality Option';
            OptionMembers = "Very Low","Low","Medium","High","Very High","Custom";
            InitValue = "Low";

            trigger OnValidate()
            begin
                case rec."Quality Option" of
                    "Quality Option"::"Very Low":
                        rec."Quality Value" := 0.2;
                    "Quality Option"::"Low":
                        rec."Quality Value" := 0.4;
                    "Quality Option"::"Medium":
                        rec."Quality Value" := 0.6;
                    "Quality Option"::"High":
                        rec."Quality Value" := 0.8;
                    "Quality Option"::"Very High":
                        rec."Quality Value" := 1;
                end;
            end;

        }
        field(4; "Quality Value"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Image Jpeg Quality %';
            MinValue = 0.0;
            MaxValue = 1.0;
            InitValue = 0.4;

            trigger OnValidate()
            begin
                case true of
                    Rec."Quality Value" = 0.2:
                        Rec."Quality Option" := Rec."Quality Option"::"Very Low";
                    Rec."Quality Value" = 0.4:
                        Rec."Quality Option" := Rec."Quality Option"::Low;
                    Rec."Quality Value" = 0.6:
                        Rec."Quality Option" := Rec."Quality Option"::Medium;
                    Rec."Quality Value" = 0.8:
                        Rec."Quality Option" := Rec."Quality Option"::High;
                    Rec."Quality Value" = 1.0:
                        Rec."Quality Option" := Rec."Quality Option"::"Very High";
                    else begin
                        Rec."Quality Option" := Rec."Quality Option"::Custom;
                    end;
                end;
            end;
        }
        field(5; "Pixel X"; Integer)
        {
            DataClassification = CustomerContent;
            InitValue = 1000;
            Caption = 'Pixel Width';
        }
        field(6; "Pixel Y"; Integer)
        {
            DataClassification = CustomerContent;
            InitValue = 1000;
            Caption = 'Pixel Height';
        }
    }
}