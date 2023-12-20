page 6151360 "NPR APIV1 TMTicketAccessStats"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'tmTicketAccessStats';
    EntitySetName = 'tmTicketAccessStats';
    Caption = 'PowerBI TM Ticket Access Stats';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR TM Ticket Access Stats";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.', Locked = true;
                }
                field(ticketType; Rec."Ticket Type")
                {
                    Caption = 'Ticket Type', Locked = true;
                }
                field(admissionCode; Rec."Admission Code")
                {
                    Caption = 'Admission Code', Locked = true;
                }
                field(admissionDate; Rec."Admission Date")
                {
                    Caption = 'Admission Date', Locked = true;
                }
                field(admissionHour; Rec."Admission Hour")
                {
                    Caption = 'Admission Hour', Locked = true;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code', Locked = true;
                }
                field(admissionCount; Rec."Admission Count")
                {
                    Caption = 'Admission Count', Locked = true;
                }
                field(admissionCountNeg; Rec."Admission Count (Neg)")
                {
                    Caption = 'Admission Count (Neg)', Locked = true;
                }
                field(admissionCountReEntry; Rec."Admission Count (Re-Entry)")
                {
                    Caption = 'Admission Count (Re-Entry)', Locked = true;
                }
                field(generatedCountPos; Rec."Generated Count (Pos)")
                {
                    Caption = 'Generated Count (Pos)', Locked = true;
                }
                field(generatedCountNeg; Rec."Generated Count (Neg)")
                {
                    Caption = 'Generated Count (Neg)', Locked = true;
                }
                field(highestAccessEntryNo; Rec."Highest Access Entry No.")
                {
                    Caption = 'Highest Access Entry No.', Locked = true;
                }
                field(itemNoFilter; Rec."Item No. Filter")
                {
                    Caption = 'Item No. Filter', Locked = true;
                }
                field(ticketTypeFilter; Rec."Ticket Type Filter")
                {
                    Caption = 'Ticket Type Filter', Locked = true;
                }
                field(admissionDateFilter; Rec."Admission Date Filter")
                {
                    Caption = 'Admission Date Filter', Locked = true;
                }
                field(admissionHourFilter; Rec."Admission Hour Filter")
                {
                    Caption = 'Admission Hour Filter', Locked = true;
                }
                field(admissionCodeFilter; Rec."Admission Code Filter")
                {
                    Caption = 'Admission Code Filter', Locked = true;
                }
                field(variantCodeFilter; Rec."Variant Code Filter")
                {
                    Caption = 'Variant Code Filter', Locked = true;
                }
                field(sumAdmissionCount; Rec."Sum Admission Count")
                {
                    Caption = 'Sum Admission Count', Locked = true;
                }
                field(sumAdmissionCountNeg; Rec."Sum Admission Count (Neg)")
                {
                    Caption = 'Sum Admission Count (Neg)', Locked = true;
                }
                field(sumAdmissionCountReEntry; Rec."Sum Admission Count (Re-Entry)")
                {
                    Caption = 'Sum Admission Count (Re-Entry)', Locked = true;
                }
                field(sumGeneratedCountPos; Rec."Sum Generated Count (Pos)")
                {
                    Caption = 'Sum Generated Count (Pos)', Locked = true;
                }
                field(sumGeneratedCountNeg; Rec."Sum Generated Count (Neg)")
                {
                    Caption = 'Sum Generated Count (Neg)', Locked = true;
                }
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        CurrRecordRef: RecordRef;
    begin
        CurrRecordRef.GetTable(Rec);
        PowerBIUtils.UpdateSystemModifiedAtfilter(CurrRecordRef);
    end;

    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}