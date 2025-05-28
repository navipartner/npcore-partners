table 6059874 "NPR Total Discount Header"
{
    Access = Internal;
    Caption = 'Total Discount Header';
    LookupPageID = "NPR Total Discount List";
    DrillDownPageId = "NPR Total Discount List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
                NoSeriesMgt: Codeunit "No. Series";
#ELSE
                NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
            begin
                if Code <> xRec.Code then begin
                    NoSeriesMgt.TestManual("No. Serie");
                    "No. Serie" := '';
                end;
            end;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            DataClassification = CustomerContent;
        }
        field(4; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(5; Status; Enum "NPR Total Discount Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
            begin
                NPRTotalDiscHeaderUtils.TestStatus(Rec);
            end;
        }
        field(6; "No. Serie"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }
        field(7; "Starting Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
            begin
                NPRTotalDiscHeaderUtils.CheckStartingDate(Rec);
            end;
        }
        field(8; "Ending date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
            begin
                NPRTotalDiscHeaderUtils.CheckEndingDate(Rec);
            end;
        }
        field(9; "Starting Time"; Time)
        {
            Caption = 'Start Time';
            DataClassification = CustomerContent;
        }
        field(10; "Ending Time"; Time)
        {
            Caption = 'End Time';
            DataClassification = CustomerContent;
        }

        field(11; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
            begin
                NPRTotalDiscHeaderUtils.ValidateShortcutDimCode(Rec.Code,
                                                                1,
                                                                Rec."Global Dimension 1 Code");
                Rec.Modify();
            end;
        }
        field(12; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
            begin
                NPRTotalDiscHeaderUtils.ValidateShortcutDimCode(Rec.Code,
                                                                2,
                                                                Rec."Global Dimension 2 Code");
                Rec.Modify();
            end;
        }
        field(13; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
        }
        field(14; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
        field(15; "Customer Disc. Group Filter"; Text[250])
        {
            Caption = 'Customer Disc. Group Filter';
            TableRelation = "Customer Discount Group";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
            begin
                NPRTotalDiscHeaderUtils.UpdateCustDiscountFilter(Rec);
            end;
        }

        field(16; "Step Amount Calculation"; Enum "NPR Total Discount Amount Calc")
        {
            Caption = 'Step Amount Calculation';
            DataClassification = CustomerContent;
        }

        field(17; "Discount Application"; Enum "NPR Total Discount Application")
        {
            Caption = 'Discount Application';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; "Starting date", "Starting time", "Ending date", "Ending time")
        {
        }
        key(Key3; "Ending date", "Ending time")
        {
        }
        key(Key4; Status, Priority, "Starting Date", "Ending date")
        {
        }
        key(Key5; Status, Priority, "Starting Date", "Ending date", "Customer Disc. Group Filter")
        {
        }

#IF NOT (BC17 or BC18 or BC19 or BC20)
        key(key7; SystemRowVersion)
        {
        }
#ENDIF
        key(key8; Status, Priority)
        {
        }
    }

    trigger OnDelete()
    var
        NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
    begin
        NPRTotalDiscHeaderUtils.CheckIfTotalDiscountEditable(Rec);
        NPRTotalDiscHeaderUtils.DeleteRelatedRecord(Rec);
    end;

    trigger OnInsert()
    var
        DimensionManagement: Codeunit DimensionManagement;
        NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
    begin
        NPRTotalDiscHeaderUtils.CheckIfTotalDiscountEditable(Rec);

        NPRTotalDiscHeaderUtils.UpdatePeriodDates(Rec);

        NPRTotalDiscHeaderUtils.InitNoSeries(Rec,
                                            xRec);

        DimensionManagement.UpdateDefaultDim(DATABASE::"NPR Total Discount Header",
                                            Rec.Code,
                                            Rec."Global Dimension 1 Code",
                                            Rec."Global Dimension 2 Code");

        NPRTotalDiscHeaderUtils.UpdateLines(Rec);

        Rec."Creation Date" := Today();
    end;

    trigger OnModify()
    var
        NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
    begin
        if xRec.Status = xRec.Status::Active then
            NPRTotalDiscHeaderUtils.CheckIfTotalDiscountEditable(Rec);

        NPRTotalDiscHeaderUtils.UpdateLines(Rec);

        Rec."Last Date Modified" := Today();
    end;

    trigger OnRename()
    var
        NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
    begin
        NPRTotalDiscHeaderUtils.CheckIfTotalDiscountEditable(Rec);
    end;
}
