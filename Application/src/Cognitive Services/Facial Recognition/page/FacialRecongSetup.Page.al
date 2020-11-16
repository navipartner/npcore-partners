page 6059915 "NPR Facial Recong. Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "NPR Facial Recogn. Setup";
    Caption = 'Facial Recognition Setup';
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(Activation)
            {
                field(Activate; Active)
                {
                    ApplicationArea = All;
                }
            }
            group(GeneralSetup)
            {
                Caption = 'General Setup';
                field(BaseURL; BaseURL)
                {
                    ApplicationArea = All;
                }
                field(APIKey; APIKey)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                }
            }
            group(SpecificURIs)
            {
                Caption = 'Specific URI setup';
                field(PersonGroupURI; PersonGroupURI)
                {
                    ApplicationArea = All;
                }
                field(PersonURI; PersonURI)
                {
                    ApplicationArea = All;
                }
                field(DetectFaceURI; DetectFaceURI)
                {
                    ApplicationArea = All;
                }
                field(PersonFaceURI; PersonFaceURI)
                {
                    ApplicationArea = All;
                }
                field(TrainPersonGroupURI; TrainPersonGroupURI)
                {
                    ApplicationArea = All;
                }
                field(IdentifyPersonURI; IdentifyPersonURI)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ClearAllData)
            {
                ApplicationArea = All;
                Caption = 'Clear all FR Data';
                Image = Delete;

                trigger OnAction()
                var
                    FacialRecognition: Record "NPR Facial Recognition";
                    FR: Codeunit "NPR Delete all Data";
                begin
                    if Dialog.Confirm('This will delete all Facial Recognition entries. \Do you want to proceed?') then begin
                        FacialRecognition.DeleteAll();
                        FR.Run();
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        with Rec do
            if not FindFirst() then begin
                Init();
                Insert(true);
            end;
    end;
}