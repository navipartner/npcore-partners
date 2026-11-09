const main = ({ context, toast }) => {
  const { title, message } = context.customParameters;
  toast.success(message, {
    title,
    position: "top-center",
    className: "sonner-toast--number",
  });
};
