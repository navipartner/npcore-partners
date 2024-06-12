table 6150791 "NPR AF Rec. Webhook Request"
{
    Access = Internal;

    Caption = 'Adyen Reconciliation Webhook Report Ready';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'ID';
            AutoIncrement = true;
        }
        field(10; "Webhook Reference"; Text[80])
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Webhook Reference';
        }
        field(20; "Status Code"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Status Code';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR35.0';
            ObsoleteReason = 'Not used.';
        }
        field(30; "Status Description"; Text[256])
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Status Description';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR35.0';
            ObsoleteReason = 'Not used.';
        }
        field(40; Live; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Live';
        }
        field(50; "Creation Date"; DateTime)
        {
            Editable = false;
            DataClassification = CustomerContent;
            Caption = 'Creation Date & Time';
        }
        field(60; "Report Download URL"; Text[2048])
        {
            Editable = false;
            DataClassification = CustomerContent;
            Caption = 'Report Download URL';
        }
        field(70; "Report Data"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Report Data';

            trigger OnValidate()
            var
                AdyenManagement: Codeunit "NPR Adyen Management";
            begin
                "PSP Reference" := CopyStr(AdyenManagement.GetPspReference(GetAdyenRequestData()), 1, MaxStrLen("PSP Reference"));
                if "PSP Reference" <> '' then
                    "Report Type" := AdyenManagement.DefineReportType("PSP Reference")
                else
                    "Report Type" := AdyenManagement.DefineReportType("Report Name");
            end;
        }
        field(80; "Report Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Report Name';
        }
        field(90; "PSP Reference"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'PSP Reference';

            trigger OnValidate()
            var
                AdyenManagement: Codeunit "NPR Adyen Management";
            begin
                if "PSP Reference" <> '' then
                    "Report Type" := AdyenManagement.DefineReportType("PSP Reference");
            end;
        }
        field(100; "Report Type"; Enum "NPR Adyen Report Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Report Type';
        }
        field(110; "Request Data"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Data';
        }
        field(120; Processed; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed';
        }
        field(130; "Adyen Webhook Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Adyen Webhook Entry No.';
            TableRelation = "NPR Adyen Webhook"."Entry No.";
        }
    }
    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    procedure GetAdyenRequestData(): Text
    var
        TypeHelper: Codeunit "Type Helper";
#IF BC17
        InStr: InStream;
#ENDIF
    begin
        if not "Request Data".HasValue() then
            exit('');
#IF BC17
        GetAdyenRequestDataStream(InStr);
        exit(TypeHelper.ReadAsTextWithSeparator(InStr, TypeHelper.LFSeparator()));
#ELSE
        exit(TypeHelper.ReadAsTextWithSeparator(GetAdyenRequestDataStream(), TypeHelper.LFSeparator()));
#ENDIF
    end;

#IF BC17
    procedure GetAdyenRequestDataStream(var InStr: InStream)
#ELSE
    procedure GetAdyenRequestDataStream() InStr: InStream
#ENDIF
    begin
        CalcFields("Request Data");
        "Request Data".CreateInStream(InStr, TextEncoding::UTF8);
    end;

    procedure GetReportData(): Text
    var
        TypeHelper: Codeunit "Type Helper";
#IF BC17
        InStr: InStream;
#ENDIF
    begin
        if not "Report Data".HasValue() then
            exit('');
#IF BC17
        GetReportDataStream(InStr);
        exit(TypeHelper.ReadAsTextWithSeparator(InStr, TypeHelper.LFSeparator()));
#ELSE
        exit(TypeHelper.ReadAsTextWithSeparator(GetReportDataStream(), TypeHelper.LFSeparator()));
#ENDIF
    end;

#IF BC17
    procedure GetReportDataStream(var InStr: InStream)
#ELSE
    procedure GetReportDataStream() InStr: InStream
#ENDIF
    begin
        if "Report Data".HasValue then begin
            CalcFields("Report Data");
            "Report Data".CreateInStream(InStr, TextEncoding::UTF8);
        end;
    end;
}
