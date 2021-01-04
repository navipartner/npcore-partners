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
                    ToolTip = 'Specifies the value of the Activate field';
                }
            }
            group(GeneralSetup)
            {
                Caption = 'General Setup';
                field(BaseURL; BaseURL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Base URL field';
                }
                field(APIKey; APIKey)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the API Key field';
                }
            }
            group(SpecificURIs)
            {
                Caption = 'Specific URI setup';
                field(PersonGroupURI; PersonGroupURI)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Person Group URI field';
                }
                field(PersonURI; PersonURI)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Person URI field';
                }
                field(DetectFaceURI; DetectFaceURI)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Detect Face URI field';
                }
                field(PersonFaceURI; PersonFaceURI)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Add Person Face URI field';
                }
                field(TrainPersonGroupURI; TrainPersonGroupURI)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Train Person Group URI field';
                }
                field(IdentifyPersonURI; IdentifyPersonURI)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Identify Person URI field';
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
                ToolTip = 'Executes the Clear all FR Data action';

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