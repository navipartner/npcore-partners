table 6014603 "NPR Event Report Layout"
{
    Caption = 'Event Report Layout';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Event No."; Code[20])
        {
            Caption = 'Event No.';
            DataClassification = CustomerContent;
            TableRelation = Job."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Usage; Option)
        {
            Caption = 'Usage';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Customer,Team';
            OptionMembers = " ",Customer,Team;

            trigger OnValidate()
            begin
                case Usage of
                    Usage::" ":
                        "Report ID" := 0;
                    Usage::Customer:
                        "Report ID" := Report::"NPR Event Customer Template";
                    Usage::Team:
                        "Report ID" := Report::"NPR Event Team Template";
                end;
            end;
        }
        field(5; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            DataClassification = CustomerContent;
        }
        field(11; "Layout Code"; Code[20])
        {
            Caption = 'Layout ID';
            DataClassification = CustomerContent;
            TableRelation = "Custom Report Layout".Code where("Report ID" = field("Report ID"));
            trigger OnValidate()
            begin
                Rec.TestField(Usage);
            end;
        }

        field(70; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(80; "Request Page Parameters"; Blob)
        {
            Caption = 'Request Page Parameters';
            DataClassification = CustomerContent;
        }
        field(81; "Use Req. Page Parameters"; Boolean)
        {
            Caption = 'Use Req. Page Parameters';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Rec."Use Req. Page Parameters" then
                    RunReportRequestPage()
                else begin
                    Clear(Rec."Request Page Parameters");
                    Message(RequestPageOptionsDeletedMsg);
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Event No.", "Line No.")
        {
        }
    }

    trigger OnInsert()
    begin
        InitRecord(Rec);
        Description := StrSubstNo(NewLayoutTxt, Rec."Event No.", Format(Usage));
    end;

    trigger OnModify()
    begin

    end;

    var

        NewLayoutTxt: Label '%1 %2 Layout';
        RequestPageOptionsDeletedMsg: Label 'You have cleared the report parameters. Select the check box in the field to show the report request page again.';



    procedure RunReportRequestPage()
    var
        InStr: InStream;
        OutStr: OutStream;
        Parameters: Text;
        NewParameters: Text;
    begin
        if "Request Page Parameters".HasValue() then begin
            CalcFields("Request Page Parameters");
            "Request Page Parameters".CreateInStream(InStr, TextEncoding::UTF8);
            InStr.ReadText(Parameters);
        end;
        NewParameters := Report.RunRequestPage("Report ID", Parameters);
        if NewParameters <> '' then begin
            Clear("Request Page Parameters");
            "Request Page Parameters".CreateOutStream(OutStr, TextEncoding::UTF8);
            OutStr.WriteText(NewParameters);
            "Use Req. Page Parameters" := true;
            Modify();
        end;
    end;

    local procedure InitRecord(var parEventReportLayout: Record "NPR Event Report Layout")
    var
        EventReportLayout: Record "NPR Event Report Layout";
    begin
        EventReportLayout.Reset();
        EventReportLayout.SetRange("Event No.", parEventReportLayout."Event No.");
        if EventReportLayout.FindLast() then
            parEventReportLayout."Line No." := EventReportLayout."Line No." + 10000
        else
            parEventReportLayout."Line No." := 10000;
    end;

    procedure GetParameters() ReportParameters: Text
    var
        InStr: InStream;
    begin
        if Rec."Request Page Parameters".HasValue() then begin
            Rec.CalcFields("Request Page Parameters");
            Rec."Request Page Parameters".CreateInStream(InStr, TextEncoding::UTF8);
            InStr.ReadText(ReportParameters);
        end;
    end;

    procedure PreviewReport()
    var
        ReportLayoutSelectionLocal: Record "Report Layout Selection";
        Job: Record Job;
        RecRef: RecordRef;
        ReportParameters: Text;
        EventCustomerTemplate: Report "NPR Event Customer Template";
        EventTeamTemplate: Report "NPR Event Team Template";
    begin
        ReportParameters := GetParameters();
        ReportLayoutSelectionLocal.SetTempLayoutSelected(Rec."Layout Code");
        Job.SetRange("No.", Rec."Event No.");
        RecRef.GetTable(Job);
        case Rec.Usage of
            Rec.Usage::Customer:
                begin
                    ReportParameters := EventCustomerTemplate.RunRequestPage(ReportParameters);
                    Clear(EventCustomerTemplate);
                    EventCustomerTemplate.Execute(ReportParameters, RecRef);
                end;
            Rec.Usage::Team:
                begin
                    ReportParameters := EventTeamTemplate.RunRequestPage(ReportParameters);
                    Clear(EventTeamTemplate);
                    EventTeamTemplate.Execute(ReportParameters, RecRef);
                end;
        end;
        ReportLayoutSelectionLocal.SetTempLayoutSelected('');
    end;
}


