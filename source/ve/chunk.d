module ve.chunk;

import ve.block;

struct Chunk(T, uint X, uint Y, uint Z)
{
    uint x = X;
    uint y = Y;
    uint z = Z;

    Block!T[X][Y][Z] blocks;

    void setBlock(uint x, uint y, uint z, Block!T block)
    {
        this.blocks[x][y][z] = block;
    }

    Block!T getBlock(uint x, uint y, uint z)
    {
        return this.blocks[x][y][z];
    }
}

unittest
{
    Chunk!(int, 16, 16, 16) c;
    assert(c.x == 16);
    assert(c.y == 16);
    assert(c.z == 16);

    auto b = c.getBlock(0, 0, 0);
    assert(b.type == 0);
    Block!int one = 1;
    c.setBlock(0, 0, 0, one);
    b = c.getBlock(0, 0, 0);
    assert(b.type == 1);

    import core.exception;
    import std.exception;

    assertThrown!RangeError(c.setBlock(999, 999, 999, one));
    assertThrown!RangeError(c.getBlock(999, 999, 999));
}
