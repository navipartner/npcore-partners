page 6014479 "NPR API V1 - Mix. Disc. Int"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Mixed Discount Time Invervals';
    DelayedInsert = true;
    EntityName = 'mixedDiscountTimeInterval';
    EntitySetName = 'mixedDiscountTimeIntervals';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Mixed Disc. Time Interv.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'systemId', Locked = true;
                }
                field(mixCode; Rec."Mix Code")
                {
                    Caption = 'mixCode', Locked = true;
                }
                field(startTime; Rec."Start Time")
                {
                    Caption = 'startTime', Locked = true;
                }
                field(endTime; Rec."End Time")
                {
                    Caption = 'endTime', Locked = true;
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'lineNo', Locked = true;
                }
                field(periodDescription; Rec."Period Description")
                {
                    Caption = 'periodDescription', Locked = true;
                }
                field(periodType; Rec."Period Type")
                {
                    Caption = 'periodType', Locked = true;
                }
                field(monday; Rec.Monday)
                {
                    Caption = 'monday', Locked = true;
                }
                field(tuesday; Rec.Tuesday)
                {
                    Caption = 'tuesday', Locked = true;
                }
                field(wednesday; Rec.Wednesday)
                {
                    Caption = 'wednesday', Locked = true;
                }
                field(thursday; Rec.Thursday)
                {
                    Caption = 'thursday', Locked = true;
                }
                field(friday; Rec.Friday)
                {
                    Caption = 'friday', Locked = true;
                }
                field(saturday; Rec.Saturday)
                {
                    Caption = 'saturday', Locked = true;
                }
                field(sunday; Rec.Sunday)
                {
                    Caption = 'sunday', Locked = true;
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
                }

                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;
}
