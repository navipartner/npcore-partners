table 6014451 "NPR Retail Journal Header"
{
    // //-NPR3.0e oversættelser v.simon
    // NPR5.41/NPKNAV/20180427  CASE 309131 Transport NPR5.41 - 27 April 2018
    // NPR5.46/JDH /20181002 CASE 294354  Renamed Variables. Cleanup, and more functionality to support easier usage of Retail Journal
    // NPR5.49/BHR /20190220 CASE 344000  Update Retail Journal Lines

    Caption = 'Label Printing Header';
    LookupPageID = "NPR Retail Journal List";

    fields
    {
        field(1; "No."; Code[40])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; "Date of creation"; Date)
        {
            Caption = 'Date';
        }
        field(4; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson';
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(6; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(7; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(8; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(9; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;

            trigger OnValidate()
            var
                RetailJournalLine: Record "NPR Retail Journal Line";
            begin
                //-NPR5.46 [294354]
                //-NPR5.41 [309131]
                // RetailJournalLine.SETRANGE("No.", Rec."No.");
                // RetailJournalLine.MODIFYALL("Location Filter", Rec."Location Code", TRUE);
                //+NPR5.41
                //+NPR5.46 [294354]
            end;
        }
        field(20; "Register No."; Code[20])
        {
            Caption = 'Cash Register No.';
            TableRelation = "NPR Register";
        }
        field(30; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            TableRelation = "Customer Price Group";
        }
        field(40; "Customer Disc. Group"; Code[20])
        {
            Caption = 'Customer Disc. Group';
            TableRelation = "Customer Discount Group";
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        RetailJournalLine.Reset;
        RetailJournalLine.SetRange("No.", "No.");
        RetailJournalLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            RetailSetup.Get;
            RetailSetup.TestField("Retail Journal No. Management");
            NoSeriesMgt.InitSeries(RetailSetup."Retail Journal No. Management", xRec."No. Series", 0D, "No.", "No. Series");
        end;

        "Date of creation" := Today;
    end;

    trigger OnModify()
    begin
        //-NPR5.49 [344000]
        UpdateJournalLines;
        //+NPR5.49 [344000]
    end;

    var
        RetailSetup: Record "NPR Retail Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        RetailJournalLine: Record "NPR Retail Journal Line";

    procedure AssistEdit(old: Record "NPR Retail Journal Header"): Boolean
    var
        this: Record "NPR Retail Journal Header";
    begin
        with this do begin
            this := Rec;
            RetailSetup.Get;
            RetailSetup.TestField("Retail Journal No. Management");
            if NoSeriesMgt.SelectSeries(RetailSetup."Retail Journal No. Management", old."No. Series", "No. Series") then begin
                NoSeriesMgt.SetSeries("No.");
                Rec := this;
                exit(true);
            end;
        end;
    end;

    procedure SetPrintQuantityByInventory()
    begin
        //-NPR5.46 [294354]
        RetailJournalLine.Reset;
        RetailJournalLine.SetRange("No.", "No.");
        if RetailJournalLine.FindSet then
            repeat
                RetailJournalLine.SetFilter("Location Filter", "Location Code");
                RetailJournalLine.CalcFields(Inventory);
                if RetailJournalLine.Inventory >= 0 then begin
                    RetailJournalLine."Quantity to Print" := RetailJournalLine.Inventory;
                    RetailJournalLine.Modify;
                end;
            until RetailJournalLine.Next = 0;
        //+NPR5.46 [294354]
    end;

    local procedure UpdateJournalLines()
    var
        RetailJournalLine1: Record "NPR Retail Journal Line";
    begin
        //-NPR5.49 [344000]
        if ("Shortcut Dimension 1 Code" <> xRec."Shortcut Dimension 1 Code") or
          ("Shortcut Dimension 2 Code" <> xRec."Shortcut Dimension 2 Code") or
          ("Location Code" <> xRec."Location Code") then begin

            RetailJournalLine1.SetRange("No.", "No.");
            if RetailJournalLine1.FindSet then
                repeat
                    RetailJournalLine1."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
                    RetailJournalLine1."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
                    RetailJournalLine1."Location Code" := "Location Code";
                    RetailJournalLine1.Modify;
                until RetailJournalLine1.Next = 0;
        end;
        //+NPR5.49 [344000]
    end;
}

