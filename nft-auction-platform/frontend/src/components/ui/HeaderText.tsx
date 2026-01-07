

export default function HeaderText({
    title
}: {
    title: string;
}) {
    return(
        <h2 className="text-4xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-indigo-600 via-purple-600 to-pink-600 mb-6 animate-pulse">
          {title}
        </h2>
    );
}