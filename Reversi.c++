#include<iostream>
using namespace std;
int ver[] = {-1, 1, 0, 0, 1,-1, 1,-1};
int hor[] = { 0, 0, 1,-1, 1, 1,-1,-1};
int board[64];
int score[2];

bool valid_index(int up,int down)
{
	if(up<0 || up > 7 || down < 0 || down > 7) return false;
	return true;
}

bool valid(int chance,int row,int col)
{
	int i,up,down; int flips = 0; int flips_local;
	if(board[row*8+col]!=2) return false;
	for(i=0;i<8;i++)
	{
		up = ver[i]+row; down = hor[i]+col; flips_local = 0;
		if(!valid_index(up,down)) continue;
		while(board[up*8+down] == 1-chance)
		{	
			flips_local++;
			up += ver[i]; down += hor[i]; if(!valid_index(up,down)) break;
		}
		if(valid_index(up,down) && board[up*8+down] == chance) flips += flips_local;
	}
	if(flips > 0) return true;
	return false;
}

bool is_possible(int chance)
{
	int i,j;
	for(i=0;i<8;i++)
	{
		for(j=0;j<8;j++)
		{
			if(board[i*8+j] == 2 && valid(chance,i,j))
				return true;
		}
	}
	return false;
}

void go(int chance,int row,int col)
{
	int i,up,down, up1,down1; int flips_local;
	board[row*8+col] = chance; score[chance]++;
	
	for(i=0;i<8;i++)
	{
		up = ver[i]+row; down = hor[i]+col; flips_local = 0;
		if(!valid_index(up,down)) continue;
		while(board[up*8+down] == 1-chance)
		{
			flips_local++;
			up += ver[i]; down += hor[i]; if(!valid_index(up,down)) break;
		}
		if(valid_index(up,down) && (board[up*8+down] == chance) && flips_local > 0)
		{
			up1 = ver[i]+row; down1 = hor[i] + col;
			while(!(up1 == up && down1 == down))
			{
				board[up1*8+down1] = chance;
				score[chance]++;
				score[1-chance]--;
				up1 += ver[i]; down1 += hor[i];
			}
		}
	}
	return ;
}

void print()
{
	int i,j;
	cout<<"  ";
	for(i=1;i<9;i++)
		cout<<i<<" ";
	cout<<"\n";
	for(i=0;i<8;i++)
	{
		cout<<i+1<<' ';
		for(j=0;j<8;j++)
		{
			if(board[i*8+j] == 2) cout<<"_ ";
			else
			cout<<board[i*8+j]<<" ";
		}
		cout<<"\n";
	}
}

int main()
{
	int i,j,k, chance, col, row;
	score[0] = 2; score[1] = 2;
	chance = 0;

	// 2 -> _
	// 0 -> B chance = 0
	// 1 -> W chance = 1

	for(i=0;i<8;i++)
		for(j=0;j<8;j++)
			board[i*8+j] = 2;
	board[3*8+3] = board[4*8+4] = 1;
	board[3*8+4] = board[4*8+3] = 0;
	print();	
	while(1)
	{
		if(score[0] + score[1] == 64) break;
		if(!is_possible(chance) && !is_possible(1-chance)) break;
		if(!is_possible(chance)) { chance = 1-chance; continue; }
		if(chance == 0) cout<<"Black\n";
		else cout<<"White\n";

		cin>>row>>col; row--; col--;
		if(!valid(chance,row,col)) { cout<<"INVALID MOVE\n"; continue; }
		go(chance ,row, col);
		print();
		chance = 1-chance;
		cout<<"Black -> "<<score[0]<<"\n";
	 	cout<<"White -> "<<score[1]<<"\n";
	}
	return 0;
}