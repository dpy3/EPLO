function mmu =updateMuPV(win,lost,mu,Np,dim) %update meanVector belong [-1,1];
mmu=mu;
for k=1:dim
    dm =(1/Np)*(win(k)-lost(k));
    if (abs(mu(k)+dm)<=1)
        mmu(k)=mu(k)+dm;
    end
end
end