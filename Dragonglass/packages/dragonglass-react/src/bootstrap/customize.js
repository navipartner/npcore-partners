// TODO: This should be done by Major Tom!
export const customizeTop = () => {
    const style = `
        <style>
          .task-dialog {
            max-width: initial !important;
          }
          .task-dialog-content-alignbox {
            width: 100% !important;
          }
        </style>";
    `;

    $("body", window.top.document).append($(style));
};
