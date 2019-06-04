package set_class;

import java.util.ArrayList;

/**
 * Class khai báo các thuộc tính và phương thức của câu hỏi tự luận
 * 
 * @author Hoảng Hải Đăng
 *
 */
public class TuLuan extends CauHoi {
	private String dapAn;

	public TuLuan(String id, String monHoc, ArrayList<String> chuong, String doKho, String deBai, String dapAn) {
		super(id, monHoc, chuong, doKho, deBai);
		this.dapAn = dapAn;
	}

	public TuLuan() {

	}

	public String getDapAn() {
		return dapAn;
	}

	public void setDapAn(String dapAn) {
		this.dapAn = dapAn;
	}

	@Override
	public String toString() {
		return this.getId();
	}
}
