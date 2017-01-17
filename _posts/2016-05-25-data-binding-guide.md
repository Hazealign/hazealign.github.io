---
layout: post
title: "[번역] ButterKnife, 지금까지 고마웠어. Data Binding, 앞으로 잘 부탁해."
date: 2016-05-25 15:00:00 +0900
categories: Code
tags: android butterknife dependencyinjection di development
---

이 글은 @izumin5210님이 Qiita에 올린 [글](http://qiita.com/izumin5210/items/2784576d86ce6b9b51e6)을 번역한 글입니다. 일부 오역이나 의역이 있을 수 있으며 이 부분에 대해서 양해를 부탁드리며, 좋은 글을 한국어로도 번역할 수 있게 해주신 izumin5210님께 감사하다는 말씀 드립니다.

## ButterKnife, 지금까지 고마웠어.

어떤 어플리케이션의 master 브랜치에 [ButterKnife](http://jakewharton.github.io/butterknife/)로 되어있던 부분을 없애는 Pull Request를 머지했다.

![]({{ site.url }}/assets/images/20160525/5.png)

지금까지 ButterKnife가 하고 있던 일은 전부 [Data Binding](http://developer.android.com/tools/data-binding/guide.html)이 대신 하게 되었다. Data Binding은 공식에서는 아직 beta release 단계에 있는 상태로, [거의 1.0에 가까운 RC(Release Candidate) 수준](https://bintray.com/android/android-tools)까지 되었기 때문에 실전에 투입할 수 있게 되었다.

실행할 때에 Reflection을 하는 ButterKnife와는 달리 Data Binding은 Annotation Processing으로 사전에 이것저것 해주는 방식이 좋았다. (c.f. ButterKnife도 Annotation Processing을 하는 방식으로 바뀌는 것 같다. -> [Split the compiler and runtime into separate artifacts. by serj-lotutovici · Pull Request #323 · JakeWharton/butterknife](https://github.com/JakeWharton/butterknife/pull/323))

"Data Binding으로 ButterKnife를 대체할 수 있다!"라고 말하는 사람들은 많지만 실제 사례를 별로 본 적이 없는 것 같아서 여기에 소개해두도록 하겠다.

## Yet Another ButterKnife로의 Data Binding

### View Binding

#### Before

아마 모두들 ButterKnife에서 제일 원하고 있는 기능, `findViewById(int id)`가 필요 없어지는 다음과 같은 코드

{% highlight java %}
class ExampleActivity extends Activity {
  @Bind(R.id.title) TextView title;
  @Bind(R.id.subtitle) TextView subtitle;
  @Bind(R.id.footer) TextView footer;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.simple_activity);
    ButterKnife.bind(this);
  }
}
{% endhighlight %}

이 부분은 전부 Data Binding으로 다음과 같이 바꿔서 사용할 수 있다.

#### After

레이아웃 전체를 `<layout></layout>`으로 감싸준다.

{% highlight xml %}
<layout>
  <LinearLayout>
    <TextView android:id="@+id/title">
    <TextView android:id="@+id/subtitle">
    <TextView android:id="@+id/footer">
  </LinearLayout>
</layout>
{% endhighlight %}

이렇게 하면 `activity_sample.xml` 파일이라고 한다면 `ActivitySampleBinding`이라는 클래스가 생성된다.`DataBindingUtils.setContentView(Activity activity, int id)`를 통해 Binding 인스턴스를 반환하기 때문에 이 인스턴스를 유지해두면 좋다.

{% highlight java %}
class ExampleActivity extends Activity {
  private ActivitySampleBinding binding;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    binding = DataBindingUtils.setContentView(this, R.layout.simple_activity);
  }
}
{% endhighlight %}

이 Binding 인스턴스가 id로 설정된 각 View의 인스턴스를 가지고 있는걸 확인할 수 있다.

{% highlight java %}
String text = binding.footer.getText();
{% endhighlight %}

### Non-Activity Binding

#### Before

Activity 뿐만이 아니라, 예를 들면 Fragment에서의 View Binding.

{% highlight java %}
public class FancyFragment extends Fragment {
  @Bind(R.id.button1) Button button1;
  @Bind(R.id.button2) Button button2;

  @Override
  public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
    View view = inflater.inflate(R.layout.fancy_fragment, container, false);
    ButterKnife.bind(this, view);
    // TODO Use fields...
    return view;
  }
}
{% endhighlight %}

#### After

생성된 Binding 클래스에 `bind(View view)`라는 정적 메소드가 존재하기 때문에, 그것을 이용하면 된다. 그 다음은 같다.

{% highlight java %}

public class FancyFragment extends Fragment {
  private FragmentFancyBinding binding;

  @Override
  public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
    return inflater.inflate(R.layout.fragment_fancy, container, false);
  }

  @Override
  public void onActivityCreated(Bundle savedInstanceState) {
    super.onActivityCreated(savedInstanceState);
    binding = FragmentFancyBinding.bind(getView());
  }
}
{% endhighlight %}

### View Binding (ViewHolder)

#### Before

ButterKnife를 이용하면 `ListView`를 위한 `ViewHolder`의 구현을 쉽게 할 수 있다.

{% highlight java %}
public class MyAdapter extends BaseAdapter {
  @Override
  public View getView(int position, View view, ViewGroup parent) {
    ViewHolder holder;
    if (view != null) {
      holder = (ViewHolder) view.getTag();
    } else {
      view = inflater.inflate(R.layout.list_item_sample, parent, false);
      holder = new ViewHolder(view);
      view.setTag(holder);
    }

    holder.name.setText("John Doe");
    // etc...

    return view;
  }

  static class ViewHolder {
    @Bind(R.id.title) TextView name;
    @Bind(R.id.job_title) TextView jobTitle;

    public ViewHolder(View view) {
      ButterKnife.bind(this, view);
    }
  }
}
{% endhighlight %}

#### After (ListView)

Data Binding을 이용하면 Binding 클래스가 ViewHolder와 같은 방식으로 작동하므로, 원래 `ViewHolder`가 필요 없어진다. (`RecyclerView`에 대해서는 조금 다른 이야기가 되기 때문에 후술하도록 하겠다.) Data Binding을 이용하고 있으면 setter 또한 구현 되어있기 때문에 각 View에 값을 일일히 줄 필요도 없다. (Snippet 안에 있는 주석을 참조하라.)

{% highlight java %}
public class MyAdapter extends BaseAdapter {
  @Override
  public View getView(int position, View convertView, ViewGroup parent) {
      ListItemSampleBinding binding;
      if (convertView == null) {
          binding = DataBindingUtil.inflate(inflater, R.layout.list_item_sample, parent, false);
          convertView = binding.getRoot();
          convertView.setTag(binding);
      } else {
          binding = (ListItemSampleBinding) convertView.getTag();
      }

			// 예를 들면 User의 리스트라면 항목 별로 지정하는게 아니라 User의 인스턴스를 바로 지정할 수 있다.
    
      binding.setUser(getItem(position));
      // binding.name.setText("John Doe");

      return convertView;
  }
}
{% endhighlight %}

#### After (RecyclerView)

`RecyclerView`같은 경우에는 `RecyclerView.ViewHolder`가 필수가 된다. 이 ViewHolder에 BindingHolder같은 이름을 붙이고 Binding 클래스와 연결해주도록 하면 된다.

{% highlight java %}
public class SampleRecyclerAdapter extends RecyclerView.Adapter<SampleRecyclerAdapter.BindingHolder> {

    @Override
    public RegisterableDeviceListAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
      final View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_item_sample, parent, false);
      return new BindingHolder(v);
    }

  @Override
  public void onBindViewHolder(BindingHolder holder, int position) {
    // BindingHolder#getBinding()がViewDataBindingを返すのでsetVariable()を呼んでいる
    // 専用のBinding（この場合だとListItemSampleBinding）を返すことが出来るなら普通にsetUser()でOK
    holder.getBinding().setVariable(BR.user, getItem(position));
  }

  static class BindingHolder extends RecyclerView.ViewHolder {
    private final ViewDataBinding binding;

    public BindingHolder(View itemView) {
      super(itemView);
      binding = DataBindingUtil.bind(itemView)
    }

    public ViewDataBinding getBinding() {
      return binding;
    }
  }
}
{% endhighlight %}

### Listener Binding (onClick)

#### Before

`@OnClick`이나 `@OnItemClick` 등의 어노테이션을 사용하는걸 통해 `setOnClickListener()`를 지정해주는 것과 비슷한 것을 할 수 있습니다.

{% highlight java %}
@OnClick(R.id.submit)
public void submit(View view) {
  // TODO submit data to server...
}
{% endhighlight %}

#### After

레이아웃에 Activity의 인스턴스를 지정해주고, `Button`의 `android:onClick` 항목에 Listener 메소드를 지정해준다.

{% highlight xml %}
<layout>
  <data>
    <variable name="activity" type="info.izumin.android.databindingsample.SampleActivity" />
  </data>
  <LinearLayout>
    <Button android:onClick="@{activity.onSampleButtonClick}">
  </LinearLayout>
</layout>
{% endhighlight %}

Activity의 `onCreate()`에서는 Binding 인스턴스에 Activity의 인스턴스를 지정해주면 그 이후에는 편하게 사용할 수 있다.

{% highlight java %}
class SampleActivity extends Activity {
  private ActivitySampleBinding binding;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    binding = DataBindingUtils.setContentView(this, R.layout.simple_activity);
    binding.setActivity(this);
  }

  public void onSampleButtonClick(View view) {
    // do something...
  }
}
{% endhighlight %}

다만, 앞의 예제의 Activity는 Layout를 참고하고 있으며 Layout은 Activity를 참조하고 있는 것처럼 완전히 서로 결합되는 구조가 된다. 이것이 싫다면 이벤트 처리만을 담당하는 Interface를 만들어주면 좋다. 이제 느슨하게 서로 연결되는 구조가 실현된다.

{% highlight java %}
interface SampleActivityHandlers {
  void onSampleButtonClick(View view);
}
{% endhighlight %}

[Clean Architecture](http://blog.8thlight.com/uncle-bob/2012/08/13/the-clean-architecture.html)에서 이야기하는 Controller에 해당될려나?

### 그 외 Data Binding의 편리한 기능들

#### Listener Bindings

Data Binding은 `@BindingAdapter`나 `@BindingMethod`라고 하는 어노테이션을 이용한 어노테이션 프로세싱을 통해 `OnClickListener` 이외의 Event Listener도 설정할 수 있다.

{% highlight xml %}
<Button android:onClick="@{handlers.onPrevButtonClick}" />
<Button android:onClick="@{handlers.onNextButtonClick}" />
<EditText android:onTextChanged="@{handlers.onTextChanged}" />
<ListView android:onScroll="@{handlers.onScroll}" />
{% endhighlight %}

{% highlight java %}
interface SampleActivityHandlers {
  void onPrevButtonClick(View view);
  void onNextButtonClick(View view);
  void onTextChanged(CharSequence s, int start, int before, int count);
  void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount);
}
{% endhighlight %}

표준으로 제공하는 Adapter에 대해서는 [extensions/baseAdapters/.../data-binding/](https://android.googlesource.com/platform/frameworks/data-binding/+/android-6.0.0_r7/extensions/baseAdapters/src/main/java/android/databinding/adapters)에 있는 파일을 참조하길 바란다.

#### Adapter Binding

`@BindingAdapter` 및 `@BindingMethod`의 악용 사례

{% highlight java %}
@BindingMethods({
    @BindingMethod(type = SwipeRefreshLayout.class, attribute = "android:onRefresh", method = "setOnRefreshListener"),
    @BindingMethod(type = RecyclerView.class, attribute = "android:adapter", method = "setAdapter")
})
public final class ViewBindingUtils {
}
{% endhighlight %}

{% highlight java %}
public interface SampleActivityHandlers {
  void onRefresh();
}
{% endhighlight %}

{% highlight xml %}
<layout>
  <data>
    <variable name="handlers"
      type="info.izumin.android.databindingsample.SampleActivityHandlers" />
    <variable name="adapter"
      type="android.support.v7.widget.RecyclerView.Adapter" />
  </data>
  <android.support.v4.widget.SwipeRefreshLayout
    android:onRefresh="@{handlers.onRefresh}" >

    <android.support.v7.widget.RecyclerView
      android:adapter="@{adapter}" />

  </android.support.v4.widget.SwipeRefreshLayout>
</layout>
{% endhighlight %}

이렇게까지 해야할 필요성이 있는지 모르겠다.

#### Image Source Binding

"어떤 값에 따라 표시하는 이미지를 바꿀 수 없을까?"같은 것도 `BindingAdapter`를 이용하면 쉽게 할 수 있다. 정적 메소드이기 때문에 테스트도 편하게 할 수 있지 않을까?

{% highlight java %}
public final class ViewBindingUtils {
  @BindingAdapter("signalStrength")
  public static void setSignalStrengthIcon(ImageView imageView, BluetoothDevice device) {
    int resId = R.mipmap.ic_signal_weak;
    final int rssi = device.getRssi();
    if (rssi >= -40) {
      resId = R.mipmap.ic_signal_strong;
    } else if (rssi < -40 && rssi > -60){
      resId = R.mipmap.ic_signal_medium;
    }
    imageView.setImageResource(resId);
  }
}
{% endhighlight %}

{% highlight xml %}
<layout>
  <data>
    <variable name="device" type="android.bluetooth.BluetoothDevice" />
  </data>
  <LinearLayout>
    <ImageView app:signalStrength="@{device}" />
    <TextView android:text="@{device.getName()}" />
    <TextView android:text="@{device.getAddress()}" />
  </LinearLayout>
</layout>
{% endhighlight %}

`BindingAdapter`로 namespace를 쓰지 않는 것(`app`)과, `android`를 쓰는 것 중 어느 쪽이 좋은가요?

#### Data Binding on Custom View

당연하게도 Data Binding은 Custom View에서도 쓸 수 있다. `@BindingAdapter`를 잘못 사용하면 `attrs.xml`을 쓰고 `TypedArray`에서 Custom Attrs를 얻는 등의 일을 쉽게 할 수 있다. ~~그게 좋은지 나쁜지는 다른 문제로 두고~~.

{% highlight java %}
public class Pagination extends RelativeLayout {
  private ViewPaginationBinding binding;

  public Pagination(Context context) {
    this(context, null);
  }

  public Pagination(Context context, AttributeSet attrs) {
    super(context, attrs);
    binding = DataBindingUtil.inflate(LayoutInflater.from(context), R.layout.view_pagination, this, true);
  }

  public static void setListener(Pagination paginate, View target, OnPaginationClickListener listener) {
    if (listener != null) {
      target.setOnClickListener(_v -> listener.onClick(paginate));
    }
  }

  @BindingAdapter({"android:onPrevButtonClicked"})
  public static void setPrevClickListener(Pagination view, OnPaginationClickListener listener) {
    setListener(view, view.binding.btnPrevPage, listener);
  }

  @BindingAdapter({"android:onNextButtonClicked"})
  public static void setNextClickListener(Pagination view, OnPaginationClickListener listener) {
    setListener(view, view.binding.btnNextPage, listener);
  }

  public interface OnPaginationClickListener {
    void onClick(Pagination pagination);
  }
}
{% endhighlight %}

### ButterKnife에서 Data Binding으로 대체할 수 없는 기능들

#### Resource Binding

이 기능은 Data Binding에는 존재하지 않는다.

{% highlight java %}
class ExampleActivity extends Activity {
  @BindString(R.string.title) String title;
  @BindDrawable(R.drawable.graphic) Drawable graphic;
  @BindColor(R.color.red) int red; // int or ColorStateList field
  @BindDimen(R.dimen.spacer) Float spacer; // int (for pixel size) or float (for exact value) field
  // ...
}
{% endhighlight %}

#### View Lists

View Lists는 여러 View를 한 곳에 모아 처리하는 기능 같다. ~~이 글을 쓸 때 처음 안 기능이다~~.

{% highlight java %}
// 이렇게 해서…
@Bind({ R.id.first_name, R.id.middle_name, R.id.last_name })
List<EditText> nameViews;

// 이런 것들을 준비해주면…
static final ButterKnife.Action<View> DISABLE = new ButterKnife.Action<View>() {
  @Override public void apply(View view, int index) {
    view.setEnabled(false);
  }
};

// 이런 느낌으로 한번에 쓸 수 있다！
ButterKnife.apply(nameViews, DISABLE);
{% endhighlight %}

이것도 Data Binding에서는 존재하지 않는다.

## 정리
 - ButterKnife의 기능은 대체로 Data Binding으로 대체할 수 있다.
	 - Resource Binding, View Lists만 Data Binding에서 대체 불가
 - `ViewHolder` 패턴은 모두 대체할 수 있다.
	 - `RecyclerView.ViewHolder`는 Binding의 Wrapper로 감싸주면 OK
 - `@BindingAdapter`와 `@BindingMethod`를 ~~악용~~이용하면 비교적 뭐든지 할 수 있다.

## References
  - [ButterKnife](http://jakewharton.github.io/butterknife/)
  - [Data Binding Guide - Android Developers](http://developer.android.com/tools/data-binding/guide.html)
  - [Android – Data Binding 연결해봤다. – NET BIZ DIV. TECH BLOG](http://tech.recruit-mp.co.jp/mobile/android-data-binding/)
  - [The Clean Architecture - 8th Light](http://blog.8thlight.com/uncle-bob/2012/08/13/the-clean-architecture.html)
  - [extensions/baseAdapters/src/main/java/android/databinding/adapters - platform/frameworks/data-binding - Git at Google](https://android.googlesource.com/platform/frameworks/data-binding/+/android-6.0.0_r7/extensions/baseAdapters/src/main/java/android/databinding/adapters)