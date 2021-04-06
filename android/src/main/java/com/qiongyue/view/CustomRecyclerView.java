package com.qiongyue.view;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;

public class CustomRecyclerView extends RecyclerView {
    protected boolean mRequestedLayout = false;

    public CustomRecyclerView(Context context) {
        super(context);
    }

    public CustomRecyclerView( Context context, AttributeSet attrs ) {
        super(context, attrs);
        init(context);
    }

    public CustomRecyclerView ( Context context, AttributeSet attrs, int defStyle ) {
        super(context, attrs, defStyle);
        init(context);
    }

    public void init (Context context) {

    }


    @Override
    public void requestLayout() {
        super.requestLayout();
        // We need to intercept this method because if we don't our children will never update
        // Check https://stackoverflow.com/questions/49371866/recyclerview-wont-update-child-until-i-scroll
        if (!mRequestedLayout) {
            mRequestedLayout = true;
            this.post(new Runnable() {
                //@SuppressLint("WrongCall")
                @Override
                public void run() {
                    mRequestedLayout = false;
                    layout(getLeft(), getTop(), getRight(), getBottom());
                    onLayout(false, getLeft(), getTop(), getRight(), getBottom());
                }
            });
        }
    }

}
