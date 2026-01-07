
/*
You can use with

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8"></div>

To visualize the cards in a grid layout
*/

export default function InstructionCard({
    imgUrl,
    title,
    description,
}: {
    imgUrl: string;
    title: string;
    description: string;
}) {
    return (
        <div className="hover:cursor-pointer flex flex-col items-center text-center p-6 rounded-lg shadow-md transition-transform duration-300 hover:scale-105 hover:shadow-lg hover:bg-gray-100">
            <img
                src={imgUrl}
                alt={title}
                className="w-24 h-24 mb-4 transition-transform duration-300 group-hover:scale-110"
            />
            <h3 className="text-xl font-semibold text-gray-800">{title}</h3>
            <p className="text-gray-600 mt-2">{description}</p>
        </div>
    );
}