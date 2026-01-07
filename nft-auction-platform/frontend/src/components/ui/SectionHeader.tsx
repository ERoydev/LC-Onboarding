

export default function SectionHeader({
    title,
    description
}: {
    title: string;
    description: string;
}) {
    return(
        <header className="from-purple-500 to-indigo-500 py-8">
            <div className="text-center">
                <h1 className="text-4xl font-bold">{title}</h1>
                <p className="text-lg mt-2">{description}</p>
            </div>
        </header>
    );
}