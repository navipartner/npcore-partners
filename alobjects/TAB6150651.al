table 6150651 "POS View Profile"
{
    // NPR5.49/TJ /20190201 CASE 335739 New object
    // NPR5.55/TSA /20200527 CASE 406862 Added "Initial Sales View", "After End-of-Sale View"

    Caption = 'POS View Profile';
    DrillDownPageID = "POS View Profiles";
    LookupPageID = "POS View Profiles";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(10;"Client Formatting Culture ID";Text[30])
        {
            Caption = 'Client Formatting Culture ID';

            trigger OnValidate()
            begin
                if "Client Formatting Culture ID" <> xRec."Client Formatting Culture ID" then begin
                  "Client Decimal Separator" := '';
                  "Client Thousands Separator" := '';
                  DetectDecimalThousandsSeparator();
                end;
            end;
        }
        field(11;"Client Decimal Separator";Text[1])
        {
            Caption = 'Client Decimal Separator';
        }
        field(12;"Client Thousands Separator";Text[1])
        {
            Caption = 'Client Thousands Separator';
        }
        field(13;"Client Date Separator";Text[1])
        {
            Caption = 'Client Date Separator';
        }
        field(20;Picture;BLOB)
        {
            Caption = 'Picture';
            SubType = Bitmap;
        }
        field(30;"POS Theme Code";Code[10])
        {
            Caption = 'POS Theme Code';
            TableRelation = "POS Theme";
        }
        field(40;"Line Order on Screen";Option)
        {
            Caption = 'Line Order on Screen';
            OptionCaption = 'Normal (new at the end),Reverse (new on top),After Selected Line';
            OptionMembers = Normal,Reverse,AutoSplitKey;
        }
        field(50;"Initial Sales View";Option)
        {
            Caption = 'Initial Sales View';
            OptionCaption = 'Sales View,Restaurant View';
            OptionMembers = SALES_VIEW,RESTAURANT_VIEW;
        }
        field(55;"After End-of-Sale View";Option)
        {
            Caption = 'After End-of-Sale View';
            OptionCaption = 'Initial Sales View,Login View';
            OptionMembers = INITIAL_SALE_VIEW,LOGIN_VIEW;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        DetectDecimalThousandsSeparator();
    end;

    procedure DetectDecimalThousandsSeparator()
    var
        CultureInfo: DotNet npNetCultureInfo;
    begin
        if "Client Formatting Culture ID" = '' then begin
          "Client Formatting Culture ID" := CultureInfo.CurrentUICulture.Name;
        end;

        if ("Client Decimal Separator" = '') or ("Client Thousands Separator" = '') or ("Client Date Separator" = '') then begin
          CultureInfo := CultureInfo.GetCultureInfo("Client Formatting Culture ID");
          if "Client Decimal Separator" = '' then
            "Client Decimal Separator" := CultureInfo.NumberFormat.NumberDecimalSeparator;
          if "Client Thousands Separator" = '' then
            "Client Thousands Separator" := CultureInfo.NumberFormat.NumberGroupSeparator;
          if "Client Date Separator" = '' then
            "Client Date Separator" := CultureInfo.DateTimeFormat.DateSeparator;
        end;
    end;
}

