module ve.block;

struct Block(T)
{
    T type;

    this(T type)
    {
        this.type = type;
    }
}
